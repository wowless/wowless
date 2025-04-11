return function(api)
  local env = api.env
  return {
    getfenv = function(arg)
      local narg = tonumber(arg)
      local fenv = getfenv(narg and narg + 4 or arg)
      return fenv == _G and env or fenv
    end,
    GetCurrentEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(6)
    end,
    GetGlobalEnvironment = function()
      return env
    end,
    IsInGlobalEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(6) == env
    end,
    SwapToGlobalEnvironment = function()
      -- setfenv(2, env) but accounting for the api loading stack
      setfenv(6, env)
    end,
  }
end
