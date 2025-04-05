local datalua = ...
local p = datalua.build
local buildType = p.test and 'Test ' or 'Release '
return p.version, p.build, p.date, p.tocversion, '', buildType, p.tocversion
