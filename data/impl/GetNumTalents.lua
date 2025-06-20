local api, sql = ...
return function(tabIndex) -- TODO honor isInspect
  return sql(api.modules.units.player.class, tabIndex)
end
