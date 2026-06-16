local eventqueue, units = ...
return function(msg)
  eventqueue.QueueEvent(
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
end
