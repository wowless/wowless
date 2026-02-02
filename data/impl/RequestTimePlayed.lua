local events, time = ...
return function()
  time.AddTimer(0, function()
    events.SendEvent('TIME_PLAYED_MSG', 3600, 600)
  end)
end
