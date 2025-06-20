local T = ...
local t = { 1, 2, 3 }
T.check1(t, T.env.table.wipe(t))
T.assertEquals(nil, next(t))
