return function()
  return {
    GetCurrentEnvironment = function()
      -- getfenv(2) but accounting for the api loading stack
      return getfenv(5)
    end,
  }
end
