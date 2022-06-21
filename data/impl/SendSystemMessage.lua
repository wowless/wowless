local api, time, msg = ...
time.timers:push(time.stamp, function()
  api.SendEvent('CHAT_MSG_SYSTEM', msg, nil, nil, '')
end)
