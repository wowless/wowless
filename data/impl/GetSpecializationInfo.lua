-- TODO support remaining arguments
local units, sql, specIndex = ...
local player = units.guids[units.aliases.player]
return sql(player.class, player.sex, specIndex)
