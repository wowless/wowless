local api, sql = ...
return function(tabIndex, talentIndex)
  return sql(api.modules.units.player.class, tabIndex, talentIndex)
end
