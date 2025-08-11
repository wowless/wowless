local talents = ...
return function(specID, level)
  talents.pendingViewLoadoutSpecID = specID
  talents.pendingViewLoadoutLevel = level
  talents.viewLoadoutDataImported = false
end
