local function run(loglevel)
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format(fmt, ...))
    end
  end
  local api = require('wowless.api').new(log)
  require('wowless.env').init(api)
  require('wowless.loader').loader(api).loadFrameXml()
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('UPDATE_CHAT_WINDOWS')
  api.SendEvent('PLAYER_ENTERING_WORLD')
  for _, frame in ipairs(api.frames) do
    if frame.Click and frame:IsVisible() then
      frame:Click()
    end
  end
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_DISABLED')
  api.NextFrame()
  api.SendEvent('PLAYER_REGEN_ENABLED')
  api.NextFrame()
  for _, frame in ipairs(api.frames) do
    if frame:IsVisible() then
      api.RunScript(frame, 'OnEnter', true)
      api.RunScript(frame, 'OnLeave', true)
    end
  end
  api.SendEvent('PLAYER_LOGOUT')
  return api
end

return {
  run = run,
}
