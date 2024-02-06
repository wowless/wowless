local sql, soulbindsql, covenantID = ...
local t = sql(covenantID)
local soulbindIDs = {}
for id in soulbindsql(covenantID) do
  table.insert(soulbindIDs, id)
end
t.soulbindIDs = soulbindIDs
return t
