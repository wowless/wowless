local units, sql = ...
return function(tabIndex, talentIndex)
  return sql(units.player.class, tabIndex, talentIndex)
end
