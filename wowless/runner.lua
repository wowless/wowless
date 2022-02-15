local function run(cfg)
  local loglevel = cfg.loglevel or 0
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format(fmt, ...))
    end
  end
  local api = require('wowless.api').new(log)
  local loader = require('wowless.loader').loader(api, {
    otherAddonDirs = cfg.otherAddonDirs,
    rootDir = cfg.dir,
    version = cfg.version,
  })
  require('wowless.env').init(api, loader)
  if cfg.dir then
    loader.loadFrameXml()
  end
  for _, d in ipairs(cfg.otherAddonDirs or {}) do
    assert(loader.loadAddon(require('path').basename(d)))
  end
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('VARIABLES_LOADED')
  api.SendEvent('PLAYER_ENTERING_WORLD')
  api.SendEvent('TRIAL_STATUS_UPDATE')
  api.SendEvent('DISPLAY_SIZE_CHANGED')
  api.SendEvent('SPELLS_CHANGED')
  local clickBlacklist = {
    PVPReadyDialogEnterBattleButton = true,
  }
  for _, frame in ipairs(api.frames) do
    if frame.Click and frame:IsVisible() and not clickBlacklist[frame:GetName() or ''] then
      api.log(2, 'clicking %s', api.GetDebugName(frame))
      frame:Click()
    end
  end
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_DISABLED')
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_ENABLED')
  for _ = 1, 200 do
    api.NextFrame(5)
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
  if cfg.allevents then
    local eventBlacklist = {
      BARBER_SHOP_OPEN = true, -- issue #111
      CALENDAR_UPDATE_EVENT_LIST = true, -- calendar math requires better stubs
      INSTANCE_LOCK_START = true,
      INSTANCE_LOCK_WARNING = true,
      OPEN_MASTER_LOOT_LIST = true,
      PLAYER_LOGIN = true,
      PLAYER_LOGOUT = true,
      UPDATE_MASTER_LOOT_LIST = true,
    }
    local keys = {}
    for k, v in pairs(require('wowapi.data').events) do
      local flavors = {}
      for _, flavor in ipairs(v.flavors or {}) do
        flavors[flavor] = true
      end
      if not eventBlacklist[k] and not next(v.payload) and not v.flavors or flavors[cfg.version] then
        table.insert(keys, k)
      end
    end
    table.sort(keys)
    for _, k in ipairs(keys) do
      api.SendEvent(k)
    end
  end
  api.SendEvent('PLAYER_LOGOUT')
  return api
end

return {
  run = run,
}
