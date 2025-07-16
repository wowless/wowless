local api, sql = ...
return function(token, user, hold)
  local text = sql(token)
  if text then
    api.SendEvent('CHAT_MSG_TEXT_EMOTE', text, '', '', '', '', '', 0, 0, '', 0, 0, '', 0, false, false, false, false)
  else
    api.log(1, 'DoEmote(%s) called', token, tostring(user), tostring(hold))
  end
  return false
end
