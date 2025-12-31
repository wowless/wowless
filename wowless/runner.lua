local setglobaltable = require('wowless.ext').setglobaltable
local sorted = require('pl.tablex').sort

--[[
This function is very magical.

Some elune functionality, like securecall, hooksecurefunc, and
loadstring, depend on the global table of the Lua state. In wowless
we need that to be the sandbox environment. So we override the
global table, scoped to a particular runner invocation.

This does not affect wowless framework code. Any globals it
references from Lua are done via the environment table, which
remains unchanged from when it was (pre)loaded.

Any later loadstring'd framework code must be setfenv'd to the
host environment _G, since loadstring'd code is born with an
environment pointing to the current global table. See the api and
uiobject loaders for where this happens.
]]
local function withglobaltable(t, f)
  local oldt = setglobaltable(t)
  local success, ret = pcall(f)
  setglobaltable(oldt)
  assert(success, ret)
  return ret
end

-- Eagerly load this module since it writes to the global table and
-- thus withglobaltable interferes with it.
require('lfs')

local function run(cfg)
  assert(cfg, 'missing configuration')
  assert(cfg.product, 'missing product')
  local loglevel = cfg.loglevel or 0
  local time0 = os.clock()
  if cfg.output then
    io.output(cfg.output)
  end
  local function log(level, fmt, ...)
    if level <= loglevel then
      io.write(string.format('[%.3f] ' .. fmt .. '\n', os.clock() - time0, ...))
    end
  end
  local path = require('path')
  local otherAddonDirs = {}
  for _, d in ipairs(cfg.otherAddonDirs or {}) do
    local dd = path.basename(d) == '' and path.dirname(d) or d
    table.insert(otherAddonDirs, dd)
  end
  local modules = require('wowless.modules')({
    datalua = require('build.products.' .. cfg.product .. '.data'),
    loadercfg = {
      otherAddonDirs = otherAddonDirs,
      rootDir = cfg.dir,
    },
    log = log,
    loglevel = cfg.loglevel or 0,
    maxErrors = cfg.maxErrors or math.huge,
  })
  local api = modules.api
  local loader = modules.loader
  local system = modules.system
  local genv = modules.env.genv
  return withglobaltable(genv, function()
    require('wowless.env').init(modules, not cfg.dir)
    if cfg.trackenums then
      for ek, ev in pairs(genv.Enum) do
        setmetatable(ev, {
          __newindex = function(t, k, v)
            log(0, 'TRACKENUMS %s VALUE %s %s', v == nil and 'DELETING' or 'WRITING', ek, k)
            rawset(t, k, v)
          end,
        })
      end
      local enums = genv.Enum
      genv.Enum = setmetatable({}, {
        __index = enums,
        __newindex = function(_, k, v)
          log(0, 'TRACKENUMS %s %s', v == nil and 'DELETING' or 'WRITING', k)
          enums[k] = v
        end,
      })
    end
    for k, v in pairs(modules.uiobjectloader(modules)) do
      modules.uiobjecttypes.Add(k, v)
    end
    loader.initAddons()
    if cfg.dir then
      loader.loadFrameXml()
    end
    for _, d in ipairs(otherAddonDirs) do
      local addon = path.basename(d)
      local success, reason = loader.loadAddon(addon)
      if not success then
        log(1, 'failed to load %s: %s', addon, reason)
      end
    end

    local CallSafely = modules.security.CallSafely
    local CallSandbox = modules.security.CallSandbox
    local NextFrame = modules.mainloop.NextFrame
    local SendEvent = modules.events.SendEvent
    local UserData = modules.uiobjects.UserData

    local datalua = require('build.products.' .. cfg.product .. '.data')
    local runnercfg = datalua.config.runner or {}

    system.LogIn()
    SendEvent('PLAYER_LOGIN')
    SendEvent('UPDATE_CHAT_WINDOWS')
    SendEvent('VARIABLES_LOADED')
    SendEvent('PLAYER_ENTERING_WORLD', true, false)
    SendEvent('TRIAL_STATUS_UPDATE')
    SendEvent('DISPLAY_SIZE_CHANGED')
    if genv.UIParent then -- Super duper hack to unblock 10.0 UIPanel code.
      UserData(genv.UIParent):SetSize(system.GetScreenWidth(), system.GetScreenHeight())
    end
    SendEvent('SPELLS_CHANGED')
    if datalua.events.COOLDOWN_VIEWER_DATA_LOADED then
      SendEvent('COOLDOWN_VIEWER_DATA_LOADED')
    end
    if cfg.frame0 and cfg.output then
      local render = require('wowless.render')
      local screenWidth, screenHeight = system.GetScreenWidth(), system.GetScreenHeight()
      local function doit(name)
        local data = render.frames2rects(api.frames, cfg.product, screenWidth, screenHeight)
        local fn = path.join(path.dirname(cfg.output), name .. '.yaml')
        require('pl.file').write(fn, require('wowapi.yaml').pprint(data))
      end
      doit('frame0')
      doit('frame1')
      if genv.ToggleTalentFrame then
        CallSandbox(genv.ToggleTalentFrame)
        doit('frame1')
      end
      os.exit(0)
    end

    local scripts = {
      bindings = function()
        local skip = runnercfg.skip_bindings or {}
        if cfg.dir then
          for name in pairs(skip) do
            CallSafely(function()
              assert(loader.bindings[name], 'missing skip_bindings ' .. name)
            end)
          end
        end
        for name, fn in sorted(loader.bindings) do
          if skip[name] then
            log(2, 'skipping binding %s per config', name)
            skip[name] = nil
          else
            log(2, 'firing binding %s', name)
            CallSandbox(fn, 'down')
            CallSandbox(fn, 'up')
          end
        end
      end,
      clicks = function()
        for frame in api.frames:entries() do
          if frame:IsObjectType('button') and frame:IsVisible() then
            log(2, 'clicking %s', frame:GetDebugName())
            CallSafely(frame.Click, frame)
          end
        end
      end,
      combat = function()
        NextFrame()
        SendEvent('PLAYER_REGEN_DISABLED')
        NextFrame()
        SendEvent('PLAYER_REGEN_ENABLED')
      end,
      emotes = function()
        local cmds = {}
        for k, v in pairs(genv) do
          cmds[v] = k:match('^EMOTE%d+_CMD%d+$') or nil
        end
        for cmd in sorted(cmds) do
          log(2, 'firing emote chat command %s', cmd)
          modules.macrotext.RunMacroText(cmd)
        end
      end,
      enterleave = function()
        for frame in api.frames:entries() do
          if frame:IsVisible() then
            log(2, 'enter/leave %s', frame:GetDebugName())
            modules.scripts.RunScript(frame, 'OnEnter', true)
            modules.scripts.RunScript(frame, 'OnLeave', true)
          end
        end
      end,
      events = function()
        local eventBlacklist = {
          INSPECT_HONOR_UPDATE = true, -- INSPECTED_UNIT shenanigans
          INSTANCE_LOCK_START = true,
          INSTANCE_LOCK_WARNING = true,
          MAIL_INBOX_UPDATE = true, -- InboxFrame.openMailID not set when it should be
          OPEN_MASTER_LOOT_LIST = true,
          PLAYER_LOGIN = true,
          PLAYER_LOGOUT = true,
          STORE_GUILD_MASTER_INFO_RECEIVED = true, -- SelectedRealm shenanigans
          UPDATE_MASTER_LOOT_LIST = true,
          VARIABLES_LOADED = true,
        }
        local skip = runnercfg.skip_events or {}
        for k, v in sorted(datalua.events) do
          if not eventBlacklist[k] and not skip[k] then
            if v.stub == 'return ' or cfg.allevents then
              local text = 'local gencode = ...;' .. v.stub
              SendEvent(k, assert(loadstring_untainted(text))(modules.gencode))
            end
          end
        end
      end,
      loot = function()
        SendEvent('LOOT_READY', false)
        if datalua.config.runtime.send_isfromitem then
          SendEvent('LOOT_OPENED', false, false)
        else
          SendEvent('LOOT_OPENED', false)
        end
        SendEvent('LOOT_CLOSED')
      end,
      macrotext = function()
        local b = genv.ActionButton1
        if b then
          b = UserData(b)
          b:SetAttribute('type', 'macro')
          b:SetAttribute('macrotext', '/startattack')
          b:Click()
          b:SetAttribute('macrotext', '/stopattack')
          b:Click()
          b:SetAttribute('macrotext', '/startattack\n/stopattack')
          b:Click()
        end
      end,
      slashcmds = function()
        local cmds = {}
        for k, v in pairs(genv) do
          local cmd = k:match('^SLASH_(.+)1$')
          if cmd then
            cmds[cmd] = v
          end
        end
        if cfg.dir then
          for k in pairs(runnercfg.skip_slashcmds or {}) do
            CallSafely(function()
              assert(cmds[k], 'missing skip_slashcmd ' .. k)
            end)
            cmds[k] = nil
          end
        end
        for k, v in sorted(cmds) do
          log(2, 'firing chat command ' .. k .. ' via ' .. v)
          modules.macrotext.RunMacroText(v)
        end
      end,
      update = function()
        for i = 1, 12 do
          NextFrame(math.pow(2, i))
        end
      end,
    }
    local defaultScripts = {
      'clicks',
      'combat',
      'update',
      'enterleave',
      'loot',
      'macrotext',
      'bindings',
      'slashcmds',
      'emotes',
      'events',
    }
    for _, script in ipairs(cfg.scripts and { strsplit(',', cfg.scripts) } or defaultScripts) do
      local fn = scripts[script]
      if fn then
        log(1, 'running script %s', script)
        fn()
      end
    end

    SendEvent('PLAYER_LOGOUT')
    loader.saveAllVariables()

    -- Last ditch invariant check.
    for _, obj in pairs(modules.uiobjects.userdata) do
      assert(UserData(obj.luarep) == obj)
      for k, v in pairs(obj) do
        assert(type(v) ~= 'table' or (k ~= 'luarep') == not UserData(v), k)
      end
    end
    assert(issecure(), 'wowless bug: framework is tainted')

    return modules
  end)
end

return {
  run = run,
}
