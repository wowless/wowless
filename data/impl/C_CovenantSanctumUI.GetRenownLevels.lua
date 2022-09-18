local sql, covenantID = ...
local t = {}
for row in sql(covenantID) do
  table.insert(t, row)
end
return t
