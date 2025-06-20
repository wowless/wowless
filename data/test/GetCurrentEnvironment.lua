local T = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    return T.match(1, t, T.env.GetCurrentEnvironment())
  end,
  unmodified = function()
    return T.match(1, T.env, T.env.GetCurrentEnvironment())
  end,
}
