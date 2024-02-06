local api, time, units, msg = ...
time.timers:push(time.stamp, function()
  api.SendEvent('CHAT_MSG_SYSTEM', msg, units.guids[units.aliases.player].name, nil, '')
end)
