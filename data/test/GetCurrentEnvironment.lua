local T, GetCurrentEnvironment = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    return T.match(1, t, GetCurrentEnvironment())
  end,
  unmodified = function()
    return T.match(1, T.env, GetCurrentEnvironment())
  end,
}
