return function(api)
  local env = api.env
  return {
    GetCurrentEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(5)
    end,
    GetGlobalEnvironment = function()
      return env
    end,
    IsInGlobalEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(5) == env
    end,
  }
end
