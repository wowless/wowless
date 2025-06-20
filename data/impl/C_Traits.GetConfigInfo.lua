local api, sql = ...
return function(configID)
  if configID ~= api.modules.talents.activeConfigID then
    return
  end
  local player = api.modules.units.player
  local treeId, specName = sql(player.spec)
  assert(treeId, 'TraitTree lookup failed for spec ' .. player.spec)
  assert(specName, 'SpecName lookup failed for spec ' .. player.spec)

  return {
    ID = configID,
    type = api.datalua.globals.Enum.TraitConfigType.Combat,
    name = specName,
    treeIDs = { treeId },
    usesSharedActionBars = false,
  }
end
