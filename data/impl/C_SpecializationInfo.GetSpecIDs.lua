local sql, specSetID = ...
local t = {}
for specID in sql(specSetID) do
  table.insert(t, specID)
end
return t
