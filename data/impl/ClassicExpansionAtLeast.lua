local datalua = ...
local gametype = datalua.build.gametype
local elevel = require('runtime.gametypes')[gametype].expansion_level
return function(level)
  assert(level >= 0 and level <= 4294967295)
  return gametype == 'Standard' or level <= elevel
end
