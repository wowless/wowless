local units, sql = ...
return function(tabIndex) -- TODO honor isInspect
  return sql(units.player.class, tabIndex)
end
