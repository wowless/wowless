local T = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    T.check1(T.env, T.env.GetGlobalEnvironment())
  end,
  unmodified = function()
    T.check1(T.env, T.env.GetGlobalEnvironment())
  end,
}
