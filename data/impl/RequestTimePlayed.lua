local api, time = ...
time.timers:push(time.stamp, function()
  api.SendEvent('TIME_PLAYED_MSG', 3600, 600)
end)
