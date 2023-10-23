local env = ...
local ret = loadstring(select(2, ...))
if ret then
  setfenv(ret, env)
end
return ret
