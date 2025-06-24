-- TODO support remaining arguments
local api, sql = ...
return function(specIndex)
  local player = api.modules.units.player
  local specId, name, desc, icon, role, primaryStat = sql(player.class, player.sex, specIndex)
  return specId, name, desc, icon, role, primaryStat, 0, nil, 0, true
end
