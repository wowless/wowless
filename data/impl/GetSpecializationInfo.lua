-- TODO support remaining arguments
local api, sql, specIndex = ...
local player = api.modules.units.player
return sql(player.class, player.sex, specIndex)
