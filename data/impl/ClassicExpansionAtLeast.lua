local datalua = ...
local family = datalua.build.family
local elevel = datalua.config.runtime.expansion_level
return function(level)
  assert(level >= 0 and level <= 4294967295)
  return family == 'Mainline' or level <= elevel
end
