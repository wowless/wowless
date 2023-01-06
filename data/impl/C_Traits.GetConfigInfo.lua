local datalua, units, talents, sql, configID = ...
if configID ~= talents.activeConfigID then
  return
end
local player = units.guids[units.aliases.player]
local treeId, specName = sql(player.spec)
assert(treeId, 'TraitTree lookup failed for spec ' .. player.spec)
assert(specName, 'SpecName lookup failed for spec ' .. player.spec)

return {
  ID = configID,
  type = datalua.globals.Enum.TraitConfigType.Combat,
  name = specName,
  treeIDs = { treeId },
  usesSharedActionBars = false,
}
