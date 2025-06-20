local api = ...
return function(msg)
  api.modules.time.AddTimer(0, function()
    api.SendEvent('CHAT_MSG_SYSTEM', msg, api.modules.units.player.name, nil, '')
  end)
end
