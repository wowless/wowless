local api = ...
return function(msg)
  api.modules.time.AddTimer(0, function()
    api.SendEvent(
      'CHAT_MSG_SYSTEM',
      msg,
      api.modules.units.player.name,
      '',
      '',
      '',
      '',
      0,
      0,
      '',
      0,
      0,
      '',
      0,
      false,
      false,
      false,
      false
    )
  end)
end
