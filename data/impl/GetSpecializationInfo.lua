-- TODO support remaining arguments
local units, sql = ...
return function(specIndex)
  local player = units.player
  return sql(player.class, player.sex, specIndex)
end
