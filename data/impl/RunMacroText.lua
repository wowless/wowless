local api, s = ...
for _, line in ipairs({ strsplit('\n', s) }) do
  api.SendEvent('EXECUTE_CHAT_LINE', line)
end
