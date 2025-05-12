local datalua, level = ...
assert(level >= 0 and level <= 4294967295)
local gametype = datalua.build.gametype
local elevel = require('runtime.gametypes')[gametype].expansion_level
return level <= elevel
