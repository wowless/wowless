local function run(loglevel)
  local function log(level, fmt, ...)
    if level <= loglevel then
      print(string.format(fmt, ...))
    end
  end
  local api = require('wowless.api').new(log)
  require('wowless.env').init(api)
  local toc = require('datafile').path('wowui/classic/FrameXML/FrameXML.toc')
  require('wowless.loader').loader(api).loadToc(toc)
  api.SendEvent('PLAYER_LOGIN')
  api.SendEvent('PLAYER_ENTERING_WORLD')
  for _, frame in ipairs(api.frames) do
    if frame.Click and frame:IsVisible() then
      frame:Click()
    end
  end
  api.NextFrame()
  return api
end

return {
  run = run,
}
