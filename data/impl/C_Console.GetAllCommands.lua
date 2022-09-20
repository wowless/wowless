local api = ...
local t = {}
for k in require('pl.tablex').sort(api.datalua.cvars) do
  table.insert(t, { command = k })
end
return t
