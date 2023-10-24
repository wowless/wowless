local api, arg = ...
local narg = tonumber(arg)
local fenv = getfenv(narg and narg + 3 or arg)
return (fenv == _G or fenv == api.globalenv) and api.env or fenv
