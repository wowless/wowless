local datalua, eventqueue, units = ...
local deepcopy = require('pl.tablex').deepcopy
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
    table.insert(args, deepcopy(datalua.structdefaults.DiscordChatInfo))
  end
  eventqueue.QueueEvent(unpack(args))
end
