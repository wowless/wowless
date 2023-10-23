local env, arg = ...
local narg = tonumber(arg)
local fenv = getfenv(narg and narg + 3 or arg)
print(_G)
print(env)
print(fenv)
return fenv == _G and env or fenv
