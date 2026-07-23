local datalua, events, log, sql = ...
return function(token, user, hold)
  local text = sql(token)
  if text then
    local args = {
      text,
      '',
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
        username = '',
      })
    end
    if datalua.product == 'wowt' then
      args[#args].hasError = false
    end
    events.SendEvent('CHAT_MSG_TEXT_EMOTE', unpack(args))
  else
    log(1, 'DoEmote(%s) called', token, tostring(user), tostring(hold))
  end
  return false
end
