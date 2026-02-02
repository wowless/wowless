local events, time, units = ...
return function(msg)
  time.AddTimer(0, function()
    events.SendEvent(
      'CHAT_MSG_SYSTEM',
      msg,
      units.player.name,
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
