local T = ...
local function factory(k)
  return T.retn(1, T.env.C_Timer.NewTimer(k, function() end))
end
return {
  funtainer = function()
    return T.checkFuntainer(factory(0))
  end,
  negative = function()
    T.assertEquals(false, pcall(factory, -1))
  end,
  positive = function()
    T.assertEquals(true, pcall(factory, math.floor((2 ^ 32 - 1) / 1000)))
  end,
  toobig = function()
    T.assertEquals(false, pcall(factory, math.floor(2 ^ 32 - 1) / 1000 + 1))
  end,
}
