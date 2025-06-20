local datalua = ...
local p = datalua.build
local buildType = p.test and 'Test ' or 'Release '
return function()
  return p.version, p.build, p.date, p.tocversion, '', buildType, p.tocversion
end
