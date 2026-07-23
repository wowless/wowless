local T, getmetatable = ...
return {
  boolean = function()
    return T.match(1, nil, getmetatable(true))
  end,
  ['function'] = function()
    return T.match(1, nil, getmetatable(function() end))
  end,
  ['nil'] = function()
    return T.match(1, nil, getmetatable(nil))
  end,
  nothing = function()
    return T.match(2, false, 'bad argument #1 to \'?\' (value expected)', pcall(getmetatable))
  end,
  number = function()
    return T.match(1, nil, getmetatable(42))
  end,
  string = function()
    if T.wowless and T.wowless.lite then -- issue #569: real client behavior comes from
      -- RestrictedExecution.lua, which isn't loaded outside full product runs
      return
    end
    return T.match(1, T.env.string, getmetatable(''))
  end,
}
