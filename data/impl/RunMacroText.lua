local api, s = ...
local util = require('wowless.util')
for _, line in ipairs({util.strsplit('\n', s)}) do
  api.SendEvent('EXECUTE_CHAT_LINE', line)
end
