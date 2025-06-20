local api = ...
return function(specID, level)
  api.modules.talents.pendingViewLoadoutSpecID = specID
  api.modules.talents.pendingViewLoadoutLevel = level
  api.modules.talents.viewLoadoutDataImported = false
end
