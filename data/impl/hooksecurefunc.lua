local env, arg1, arg2, arg3 = ...

local function returner(...)
  return { ... }, select('#', ...)
end

local tbl, name, fn
if arg3 ~= nil then
  tbl, name, fn = arg1, arg2, arg3
else
  tbl, name, fn = env, arg1, arg2
end
local oldfn = tbl[name]
tbl[name] = function(...)
  local t, n = returner(oldfn(...))
  fn(...)
  return unpack(t, 1, n)
end
