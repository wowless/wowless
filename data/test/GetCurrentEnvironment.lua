local T = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    T.check1(t, T.env.GetCurrentEnvironment())
  end,
  unmodified = function()
    T.check1(T.env, T.env.GetCurrentEnvironment())
  end,
}
