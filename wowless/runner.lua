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
  loader.loadFrameXml()
  for _, d in ipairs(cfg.otherAddonDirs or {}) do
    loader.loadAddon(require('path').basename(d))
  end
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('VARIABLES_LOADED')
  api.SendEvent('PLAYER_ENTERING_WORLD')
  local clickBlacklist = {
    PVPReadyDialogEnterBattleButton = true,
  }
  for _, frame in ipairs(api.frames) do
    if frame.Click and frame:IsVisible() and not clickBlacklist[frame:GetName() or ''] then
      api.log(2, 'cicking %s', tostring(frame:GetName()))
      frame:Click()
    end
  end
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_DISABLED')
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_ENABLED')
  api.NextFrame()
  -- TODO remove hack hiding CovenantFollowerPlacer
  if api.env.CovenantFollowerPlacer then
    api.env.CovenantFollowerPlacer:Hide()
  end
  for _, frame in ipairs(api.frames) do
    if frame:IsVisible() then
      api.log(2, 'enter/leave %s', tostring(frame:GetName()))
      api.RunScript(frame, 'OnEnter', true)
      api.RunScript(frame, 'OnLeave', true)
    end
  end
  api.SendEvent('LOOT_READY', false)
  api.SendEvent('LOOT_OPENED', false, false)
  api.SendEvent('LOOT_CLOSED')
  do
    local b = api.env.ActionButton1
    b:SetAttribute('type', 'macro')
    b:SetAttribute('macrotext', '/startattack')
    b:Click()
    b:SetAttribute('macrotext', '/stopattack')
    b:Click()
    b:SetAttribute('macrotext', '/startattack\n/stopattack')
    b:Click()
  end
  api.SendEvent('PLAYER_LOGOUT')
  return api
end

return {
  run = run,
}
