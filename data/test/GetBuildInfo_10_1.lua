local T = ...
local b = T.data.build
T.check6(b.version, b.build, b.date, b.tocversion, '', ' ', T.env.GetBuildInfo())
