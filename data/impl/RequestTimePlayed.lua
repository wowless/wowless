local api = ...
return function()
  api.modules.time.AddTimer(0, function()
    api.SendEvent('TIME_PLAYED_MSG', 3600, 600)
  end)
end
