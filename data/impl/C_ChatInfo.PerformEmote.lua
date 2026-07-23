local events, log, sql = ...
return function(token, user, hold)
  local text = sql(token)
  if text then
    events.SendEvent('CHAT_MSG_TEXT_EMOTE', text, '', '', '', '', '', 0, 0, '', 0, 0, '', 0, false, false, false, false)
  else
    log(1, 'DoEmote(%s) called', token, tostring(user), tostring(hold))
  end
  return false
end
