local datalua = ...
local t = {}
for _, v in require('pl.tablex').sort(datalua.cvars) do
  table.insert(t, { command = v.name })
end
return t
