local api, sql = ...
return function()
  return sql(api.modules.units.player.class)
end
