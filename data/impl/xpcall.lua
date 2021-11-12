local f, e = ...
local args = {select(3, ...)}
local n = select('#', ...) - 2
return xpcall(function() f(unpack(args, 1, n)) end, e)
