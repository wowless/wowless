local T = ...
local b = T.data.build
local buildType = b.test and 'Test ' or 'Release '
T.check7(b.version, b.build, b.date, b.tocversion, '', buildType, b.tocversion, T.env.GetBuildInfo())
