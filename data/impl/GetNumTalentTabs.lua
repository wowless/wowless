local units, sql = ...
return function()
  return sql(units.player.class)
end
