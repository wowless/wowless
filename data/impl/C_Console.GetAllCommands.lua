local datalua = ...
local t = {}
for k in require('pl.tablex').sort(datalua.cvars) do
  table.insert(t, { command = k })
end
return t
