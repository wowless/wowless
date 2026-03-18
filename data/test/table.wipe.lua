local T, wipe = ...
local t = { 1, 2, 3 }
T.check1(t, wipe(t))
T.assertEquals(nil, next(t))
