local T = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    return T.match(1, false, T.env.IsInGlobalEnvironment())
  end,
  unmodified = function()
    return T.match(1, true, T.env.IsInGlobalEnvironment())
  end,
}
