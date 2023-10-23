local env = ...
local ret = loadstring_untainted(select(2, ...))
if ret then
  setfenv(ret, env)
end
return ret
