local units, sql = ...
return function(query)
  local name, icon, tier, column = sql(units.player.class, query.specializationIndex, query.talentIndex)
  if name then
    return {
      column = column,
      icon = icon,
      maxRank = 1,
      name = name,
      previewRank = 0,
      rank = 0,
      tier = tier,
    }
  end
end
