local function run(cfg)
  assert(cfg, 'missing configuration')
  assert(cfg.product, 'missing product')
  _G.loadstring = debug.newcfunction(function(...)
    return _G.loadstring_untainted(...) -- elune rewrite hack
  end)
  local loglevel = cfg.loglevel or 0
  local time0 = os.clock()
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format('[%.3f] ' .. fmt, os.clock() - time0, ...))
    end
  end
  local api = require('wowless.api').new(log, cfg.maxErrors, cfg.product)
  local loader = require('wowless.loader').loader(api, {
    cascproxy = cfg.cascproxy,
    otherAddonDirs = cfg.otherAddonDirs,
    product = cfg.product,
    rootDir = cfg.dir,
  })
  require('wowless.env').init(api, loader, not cfg.dir)
  loader.initAddons()
  if cfg.dir then
    loader.loadFrameXml()
  end
  for _, d in ipairs(cfg.otherAddonDirs or {}) do
    assert(loader.loadAddon(require('path').basename(d)))
  end
  api.states.System.isLoggedIn = true
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('VARIABLES_LOADED')
  api.SendEvent('PLAYER_ENTERING_WORLD', true, false)
  api.SendEvent('TRIAL_STATUS_UPDATE')
  api.SendEvent('DISPLAY_SIZE_CHANGED')
  if api.env.UIParent then -- Super duper hack to unblock 10.0 UIPanel code.
    api.env.UIParent:SetSize(api.states.System.screenWidth, api.states.System.screenHeight)
  end
  api.SendEvent('SPELLS_CHANGED')
  if cfg.debug then
    print('_, api = debug.getlocal(3, 5)')
    debug.debug()
    os.exit(0)
  end
  if cfg.frame0 then
    local render = require('wowless.render')
    local screenWidth, screenHeight = api.states.System.screenWidth, api.states.System.screenHeight
    local function doit(name)
      local data = render.frames2rects(api, cfg.product, screenWidth, screenHeight)
      local fn = 'out/' .. cfg.product .. '/' .. name .. '.yaml'
      require('pl.file').write(fn, require('wowapi.yaml').pprint(data))
    end
    doit('frame0')
    if api.env.ToggleTalentFrame then
      api.CallSafely(api.env.ToggleTalentFrame)
      doit('frame1')
    end
    os.exit(0)
  end

  local scripts = {
    bindings = function()
      local names = {}
      for name in pairs(api.states.Bindings) do
        table.insert(names, name)
      end
      table.sort(names)
      for _, name in ipairs(names) do
        local fn = api.states.Bindings[name]
        api.log(2, 'firing binding ' .. name)
        api.CallSafely(function()
          fn('down')
        end)
        api.CallSafely(function()
          fn('up')
        end)
      end
    end,
    clicks = function()
      local clickBlacklist = {
        PVPReadyDialogEnterBattleButton = true,
      }
      for _, frame in ipairs(api.frames) do
        if
          api.InheritsFrom(api.UserData(frame).type, 'button')
          and frame:IsVisible()
          and not clickBlacklist[frame:GetName() or '']
        then
          api.log(2, 'clicking %s', api.GetDebugName(frame))
          api.CallSafely(function()
            frame:Click()
          end)
        end
      end
    end,
    combat = function()
      api.NextFrame()
      api.SendEvent('PLAYER_REGEN_DISABLED')
      api.NextFrame()
      api.SendEvent('PLAYER_REGEN_ENABLED')
    end,
    enterleave = function()
      for _, frame in ipairs(api.frames) do
        if frame.IsVisible and frame:IsVisible() then
          api.log(2, 'enter/leave %s', api.GetDebugName(frame))
          api.RunScript(frame, 'OnEnter', true)
          api.RunScript(frame, 'OnLeave', true)
        end
      end
    end,
    events = function()
      local eventBlacklist = {
        BARBER_SHOP_OPEN = true, -- issue #111
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
        VOICE_CHAT_VAD_SETTINGS_UPDATED = true, -- inconsistent with nilable C_VoiceChat outputs
      }
      local keys = {}
      local payloads = {}
      local typeToPayload = {
        boolean = 'false',
        number = '1',
        string = '\'\'',
        table = '{}',
        unknown = 'nil',
      }
      for k, v in pairs(require('build.products.' .. cfg.product .. '.data').events) do
        if not v.neverSent and not eventBlacklist[k] then
          local payload = {}
          for _, p in ipairs(v.payload or {}) do
            local pv = typeToPayload[p.type] or 'nil'
            table.insert(payload, pv)
          end
          if not next(payload) or cfg.allevents then
            table.insert(keys, k)
            payloads[k] = loadstring('return ' .. table.concat(payload, ','))
          end
        end
      end
      table.sort(keys)
      for _, k in ipairs(keys) do
        api.SendEvent(k, payloads[k]())
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
    misc = function()
      api.SendEvent('CRAFT_SHOW')
      api.SendEvent('CRAFT_UPDATE')
      api.SendEvent('CRAFT_CLOSE')
      api.SendEvent('TRADE_SKILL_SHOW')
      api.SendEvent('TRADE_SKILL_UPDATE')
      api.SendEvent('TRADE_SKILL_CLOSE')
      api.SendEvent('GOSSIP_SHOW')
      api.SendEvent('GOSSIP_CLOSE')
      api.SendEvent('QUEST_GREETING')
      api.SendEvent('QUEST_PROGRESS')
      api.SendEvent('QUEST_FINISHED')
    end,
    slashcmds = function()
      local cmdBlacklist = { -- TODO remove this; these require a better SecureCmdOptionParse
        BENCHMARK = true,
        CASTRANDOM = true,
        EVENT = true, -- throws Lua errors if text isn't a valid event
        LOOT_MASTER = true, -- broken
        PTRFEEDBACK = true, -- this just seems broken with an empty string
        USERANDOM = true,
      }
      local cmds = {}
      for k, v in pairs(api.env) do
        local cmd = k:match('^SLASH_(.+)1$')
        if cmd and not cmdBlacklist[cmd] then
          cmds[cmd] = v
        end
      end
      for k, v in require('pl.tablex').sort(cmds) do
        api.log(2, 'firing chat command ' .. k .. ' via ' .. v)
        api.SendEvent('EXECUTE_CHAT_LINE', v)
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
    'misc',
    'bindings',
    'slashcmds',
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
  return api
end

return {
  run = run,
}
