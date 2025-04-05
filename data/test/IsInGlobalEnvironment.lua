local T = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    T.check1(false, T.env.IsInGlobalEnvironment())
  end,
  unmodified = function()
    T.check1(true, T.env.IsInGlobalEnvironment())
  end,
}
