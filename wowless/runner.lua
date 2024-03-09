local sorted = require('pl.tablex').sort
local function run(cfg)
  assert(cfg, 'missing configuration')
  assert(cfg.product, 'missing product')
  local loglevel = cfg.loglevel or 0
  local time0 = os.clock()
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format('[%.3f] ' .. fmt, os.clock() - time0, ...))
    end
  end
  local api = require('wowless.api').new(log, cfg.maxErrors, cfg.product)

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

  The fourth line is required because print depends on tostring from
  the global table. TODO remove this dependency
  ]]
  require('lfs')
  require('lsqlite3')
  require('wowless.ext').setglobaltable(api.env)
  api.env.tostring = tostring
  -- end WARNING WARNING WARNING

  local path = require('path')
  local otherAddonDirs = {}
  for _, d in ipairs(cfg.otherAddonDirs or {}) do
    local dd = path.basename(d) == '' and path.dirname(d) or d
    table.insert(otherAddonDirs, dd)
  end
  local loader = require('wowless.loader').loader(api, {
    otherAddonDirs = otherAddonDirs,
    product = cfg.product,
    rootDir = cfg.dir,
  })
  require('wowless.env').init(api, loader, not cfg.dir)
  loader.initAddons()
  if cfg.dir then
    loader.loadFrameXml()
  end
  for _, d in ipairs(otherAddonDirs) do
    assert(loader.loadAddon(path.basename(d)))
  end
  local system = api.modules.system
  system.LogIn()
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('VARIABLES_LOADED')
  api.SendEvent('PLAYER_ENTERING_WORLD', true, false)
  api.SendEvent('TRIAL_STATUS_UPDATE')
  api.SendEvent('DISPLAY_SIZE_CHANGED')
  if api.env.UIParent then -- Super duper hack to unblock 10.0 UIPanel code.
    api.env.UIParent:SetSize(system.GetScreenWidth(), system.GetScreenHeight())
  end
  api.SendEvent('SPELLS_CHANGED')
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
    if api.env.ToggleTalentFrame then
      api.CallSandbox(api.env.ToggleTalentFrame)
      doit('frame1')
    end
    os.exit(0)
  end

  local datalua = require('build.products.' .. cfg.product .. '.data')
  local runnercfg = datalua.config.runner or {}

  local scripts = {
    bindings = function()
      for name, fn in sorted(loader.bindings) do
        api.log(2, 'firing binding ' .. name)
        api.CallSandbox(fn, 'down')
        api.CallSandbox(fn, 'up')
      end
    end,
    clicks = function()
      for frame in api.frames:entries() do
        if frame:IsObjectType('button') and frame:IsVisible() then
          api.log(2, 'clicking %s', frame:GetDebugName())
          api.CallSafely(frame.Click, frame)
        end
      end
    end,
    combat = function()
      api.NextFrame()
      api.SendEvent('PLAYER_REGEN_DISABLED')
      api.NextFrame()
      api.SendEvent('PLAYER_REGEN_ENABLED')
    end,
    emotes = function()
      local cmds = {}
      for k, v in pairs(api.env) do
        cmds[v] = k:match('^EMOTE%d+_CMD%d+$') or nil
      end
      for cmd in sorted(cmds) do
        api.log(2, 'firing emote chat command %s', cmd)
        api.modules.macrotext.RunMacroText(cmd)
      end
    end,
    enterleave = function()
      for frame in api.frames:entries() do
        if frame:IsVisible() then
          api.log(2, 'enter/leave %s', frame:GetDebugName())
          api.RunScript(frame, 'OnEnter', true)
          api.RunScript(frame, 'OnLeave', true)
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
      -- TODO unify with wowapi/loader
      local mixin = require('wowless.util').mixin
      local function stubMixin(t, name)
        return mixin(t, api.env[name])
      end
      for k, v in sorted(datalua.events) do
        if v.payload and not eventBlacklist[k] and not skip[k] then
          if v.payload == 'return ' or cfg.allevents then
            local text = 'local Mixin = ...;' .. v.payload
            api.SendEvent(k, assert(loadstring(text))(stubMixin))
          end
        end
      end
    end,
    loot = function()
      api.SendEvent('LOOT_READY', false)
      api.SendEvent('LOOT_OPENED', false, false)
      api.SendEvent('LOOT_CLOSED')
    end,
    macrotext = function()
      local b = api.env.ActionButton1
      if b then
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
          api.CallSafely(function()
            assert(cmds[k], 'missing skip_slashcmd ' .. k)
          end)
          cmds[k] = nil
        end
      end
      for k, v in sorted(cmds) do
        api.log(2, 'firing chat command ' .. k .. ' via ' .. v)
        api.modules.macrotext.RunMacroText(v)
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
      fn()
    end
  end

  api.SendEvent('PLAYER_LOGOUT')
  loader.saveAllVariables()

  -- Last ditch invariant check.
  for _, obj in pairs(api.uiobjects) do
    assert(api.UserData(obj.luarep) == obj)
    for k, v in pairs(obj) do
      assert(type(v) ~= 'table' or (k ~= 'luarep') == not api.UserData(v), k)
    end
  end
  assert(issecure(), 'wowless bug: framework is tainted')

  return api, loader
end

return {
  run = run,
}
