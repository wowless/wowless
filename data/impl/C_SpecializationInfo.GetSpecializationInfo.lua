-- TODO support remaining arguments
local units, sql = ...
return function(specIndex)
  local player = units.player
  local specId, name, desc, icon, role, primaryStat = sql(player.class, player.sex, specIndex)
  return specId, name, desc, icon, role, primaryStat, 0, nil, 0, true
end
