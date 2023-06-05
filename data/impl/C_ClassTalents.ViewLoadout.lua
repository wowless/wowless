local talentState, specLookupSql, importData = ...

talentState.viewLoadoutDataImported = false

local pendingSpecID = talentState.pendingViewLoadoutSpecID
if specLookupSql(pendingSpecID, 1) ~= nil then
  talentState.viewLoadoutSpecID = pendingSpecID
  talentState.viewLoadoutDataImported = true
end

return talentState.viewLoadoutSpecID ~= nil and type(importData) == 'table'
