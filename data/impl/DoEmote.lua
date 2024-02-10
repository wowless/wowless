local api, sql, token, user, hold = ...
local text = sql(token)
if text then
  api.SendEvent('CHAT_MSG_TEXT_EMOTE', text, '', '', '', '', '', 0, 0, '', 0, 0)
else
  api.log(1, 'DoEmote(%s) called', token, tostring(user), tostring(hold))
end
return false
