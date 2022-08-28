local function run(cfg)
  assert(cfg, 'missing configuration')
  assert(cfg.product, 'missing product')
  _G.loadstring = _G.loadstring_untainted or _G.loadstring -- tainted-lua rewrite hack
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
  require('wowless.env').init(api, loader, cfg.taint)
  if not cfg.dir then -- Hack for addon_spec :(
    api.env.GetCVar = api.env.C_CVar.GetCVar
    api.env.print = function() end
  end
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
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_DISABLED')
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_ENABLED')
  for i = 1, 12 do
    api.NextFrame(math.pow(2, i))
  end
  for _, frame in ipairs(api.frames) do
    if frame:IsVisible() then
      api.log(2, 'enter/leave %s', api.GetDebugName(frame))
      api.RunScript(frame, 'OnEnter', true)
      api.RunScript(frame, 'OnLeave', true)
    end
  end
  api.SendEvent('LOOT_READY', false)
  api.SendEvent('LOOT_OPENED', false, false)
  api.SendEvent('LOOT_CLOSED')
  do
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
  end
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
  do
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
  end
  do
    local cmdBlacklist = { -- TODO remove this; these require a better SecureCmdOptionParse
      BENCHMARK = true,
      CASTRANDOM = true,
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
  end
  local eventBlacklist = {
    BARBER_SHOP_OPEN = true, -- issue #111
    INSPECT_HONOR_UPDATE = true, -- INSPECTED_UNIT shenanigans
    INSTANCE_LOCK_START = true,
    INSTANCE_LOCK_WARNING = true,
    MAIL_INBOX_UPDATE = true, -- InboxFrame.openMailID not set when it should be
    OPEN_MASTER_LOOT_LIST = true,
    PARTY_INVITE_CANCEL = true, -- broken on vanilla
    PLAYER_LOGIN = true,
    PLAYER_LOGOUT = true,
    UPDATE_MASTER_LOOT_LIST = true,
    VARIABLES_LOADED = true,
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
    if not eventBlacklist[k] then
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
  if api.states.Addons.KethoDoc then
    api.env.KethoDoc:DumpWidgetAPI()
    print(api.env.KethoEditBox.EditBox:GetText())
  end
  api.SendEvent('PLAYER_LOGOUT')
  loader.saveAllVariables()
  return api
end

return {
  run = run,
}
