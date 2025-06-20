local api, specLookupSql = ...
return function(importData)
  api.modules.talents.viewLoadoutDataImported = false
  local pendingSpecID = api.modules.talents.pendingViewLoadoutSpecID
  if specLookupSql(pendingSpecID, 1) ~= nil then
    api.modules.talents.viewLoadoutSpecID = pendingSpecID
    api.modules.talents.viewLoadoutDataImported = true
  end
  return api.modules.talents.viewLoadoutSpecID ~= nil and type(importData) == 'table'
end
