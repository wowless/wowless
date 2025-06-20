-- TODO support remaining arguments
local api, sql = ...
return function(specIndex)
  local player = api.modules.units.player
  return sql(player.class, player.sex, specIndex)
end
