local api, units, msg = ...
api.modules.time.AddTimer(0, function()
  api.SendEvent('CHAT_MSG_SYSTEM', msg, units.guids[units.aliases.player].name, nil, '')
end)
