local datalua, eventqueue, units = ...
return function(msg)
  local args = {
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
    false,
  }
  if datalua.config.runtime.discord then
    table.insert(args, {
      forwardedMessage = '',
      fromDiscord = false,
      globalName = '',
      hasAttachment = false,
      hasEmbed = false,
      hasEmoji = false,
      hasForwardedMessage = false,
      hasPoll = false,
      hasSticker = false,
      lastOnlineGUID = '',
      lastOnlineName = '',
      type = 0,
      userID = '',
    })
  end
  eventqueue.QueueEvent(unpack(args))
end
