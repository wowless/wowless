local units, sql, tabIndex, talentIndex = ...
if sql then
  tabIndex = assert(tonumber(tabIndex), 'invalid tabIndex')
  talentIndex = assert(tonumber(talentIndex), 'invalid talentIndex')
  return sql(units.guids[units.aliases.player].class, tabIndex, talentIndex)
end
