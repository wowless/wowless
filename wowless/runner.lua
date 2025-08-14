local sorted = require('pl.tablex').sort
local function run(cfg)
  assert(cfg, 'missing configuration')
  assert(cfg.product, 'missing product')
  local loglevel = cfg.loglevel or 0
  local time0 = os.clock()
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

  -- begin WARNING WARNING WARNING
  --[[
  The following lines of code are very magical.

  The third line sets the global table for this Lua state to the
  sandbox env table. This is necessary for the correct behavior of
  some elune functionality, like securecall, hooksecurefunc,
  and loadstring.

  This does not affect wowless framework code. Any globals it
  references from Lua are done via the environment table, which
  remains unchanged from when it was (pre)loaded.

  Any later loadstring'd framework code must be setfenv'd to the
  host environment _G, since loadstring'd code is born with an
  environment pointing to the current global table. See the api and
  uiobject loaders for where this happens.

  The first and second lines eagerly load modules which write to
  the global table.
  ]]
  require('lfs')
  require('lsqlite3')
  require('wowless.ext').setglobaltable(api.env)
  -- end WARNING WARNING WARNING

  local loader = modules.loader
  require('wowless.env').init(modules, not cfg.dir)
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

  local SendEvent = modules.events.SendEvent
  local CallSafely = modules.security.CallSafely
  local CallSandbox = modules.security.CallSandbox

  local system = modules.system
  system.LogIn()
  SendEvent('PLAYER_LOGIN')
  SendEvent('UPDATE_CHAT_WINDOWS')
  SendEvent('VARIABLES_LOADED')
  SendEvent('PLAYER_ENTERING_WORLD', true, false)
  SendEvent('TRIAL_STATUS_UPDATE')
  SendEvent('DISPLAY_SIZE_CHANGED')
  if api.env.UIParent then -- Super duper hack to unblock 10.0 UIPanel code.
    api.UserData(api.env.UIParent):SetSize(system.GetScreenWidth(), system.GetScreenHeight())
  end
  SendEvent('SPELLS_CHANGED')
  if cfg.debug then
    print('_, api = debug.getlocal(3, 5)')
    debug.debug()
    os.exit(0)
  end
  if cfg.frame0 then
    local render = require('wowless.render')
    local screenWidth, screenHeight = system.GetScreenWidth(), system.GetScreenHeight()
    local function doit(name)
      local data = render.frames2rects(api, cfg.product, screenWidth, screenHeight)
      local fn = 'out/' .. cfg.product .. '/' .. name .. '.yaml'
      require('pl.file').write(fn, require('wowapi.yaml').pprint(data))
    end
    doit('frame0')
    doit('frame1')
    if api.env.ToggleTalentFrame then
      CallSandbox(api.env.ToggleTalentFrame)
      doit('frame1')
    end
    os.exit(0)
  end

  local datalua = require('build.products.' .. cfg.product .. '.data')
  local runnercfg = datalua.config.runner or {}

  local scripts = {
    bindings = function()
      for name, fn in sorted(loader.bindings) do
        log(2, 'firing binding ' .. name)
        CallSandbox(fn, 'down')
        CallSandbox(fn, 'up')
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
      api.NextFrame()
      SendEvent('PLAYER_REGEN_DISABLED')
      api.NextFrame()
      SendEvent('PLAYER_REGEN_ENABLED')
    end,
    emotes = function()
      local cmds = {}
      for k, v in pairs(api.env) do
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
      local b = api.env.ActionButton1
      if b then
        b = api.UserData(b)
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
      for k, v in pairs(api.env) do
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
        api.NextFrame(math.pow(2, i))
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
    assert(api.UserData(obj.luarep) == obj)
    for k, v in pairs(obj) do
      assert(type(v) ~= 'table' or (k ~= 'luarep') == not api.UserData(v), k)
    end
  end
  assert(issecure(), 'wowless bug: framework is tainted')

  return modules
end

return {
  run = run,
}
