local mixin = require('wowless.util').mixin
return function()
  local genv = {}
  local secureenv = {}
  return {
    genv = genv,
    getfenv = function(arg)
      local narg = tonumber(arg)
      local fenv = getfenv(narg and narg + 2 or arg)
      return fenv == _G and genv or fenv
    end,
    GetCurrentEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(3)
    end,
    GetGlobalEnvironment = function()
      return genv
    end,
    IsInGlobalEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(3) == genv
    end,
    mixin = function(t, k)
      return mixin(t, genv[k])
    end,
    secureenv = secureenv,
    SwapToGlobalEnvironment = function()
      -- setfenv(2, genv) but accounting for the api loading stack
      setfenv(3, genv)
    end,
  }
end
