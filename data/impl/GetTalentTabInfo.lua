local units, sql = ...
return function(tabIndex) -- TODO honor isInspect
  local name, filename = sql(units.player.class, tabIndex)
  return nil, name, nil, nil, 0, filename, 0, false
end
