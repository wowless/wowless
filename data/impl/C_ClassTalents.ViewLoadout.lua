local talents, specLookupSql = ...
return function(importData)
  talents.viewLoadoutDataImported = false
  local pendingSpecID = talents.pendingViewLoadoutSpecID
  if specLookupSql(pendingSpecID, 1) ~= nil then
    talents.viewLoadoutSpecID = pendingSpecID
    talents.viewLoadoutDataImported = true
  end
  return talents.viewLoadoutSpecID ~= nil and type(importData) == 'table'
end
