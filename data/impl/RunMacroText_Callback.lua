local api, s = ...
if api.macroExecuteLineCallback then
  for _, line in ipairs({ strsplit('\n', s) }) do
    api.macroExecuteLineCallback(line)
  end
end
