local T, IsInGlobalEnvironment = ...
return {
  modified = function()
    local t = {}
    setfenv(1, t)
    return T.match(1, false, IsInGlobalEnvironment())
  end,
  unmodified = function()
    return T.match(1, true, IsInGlobalEnvironment())
  end,
}
