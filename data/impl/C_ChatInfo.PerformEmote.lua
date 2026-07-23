local datalua, events, log, sql = ...
local deepcopy = require('pl.tablex').deepcopy
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
      table.insert(args, deepcopy(datalua.structdefaults.DiscordChatInfo))
    end
    events.SendEvent('CHAT_MSG_TEXT_EMOTE', unpack(args))
  else
    log(1, 'DoEmote(%s) called', token, tostring(user), tostring(hold))
  end
  return false
end
