local T = ...
local function success(val, arg)
  return T.match(1, val, T.env.ClassicExpansionAtLeast(arg))
end
local function failure(...)
  return T.assertEquals(false, (pcall(T.env.ClassicExpansionAtLeast, ...)))
end
return {
  ['-1'] = function()
    return failure(-1)
  end,
  ['0'] = function()
    return success(true, 0)
  end,
  ['4294967295'] = function()
    return success(T.data.build.gametype == 'Standard', 4294967295)
  end,
  ['4294967296'] = function()
    return failure(4294967296)
  end,
  ['math.huge'] = function()
    return failure(math.huge)
  end,
  ['missing'] = function()
    return failure()
  end,
  ['type'] = function()
    return failure({})
  end,
}
