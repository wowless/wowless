local T = ...
local f = T.env.C_Timer.NewTimer
local function factory(k)
  return T.retn(1, f(k, function() end))
end
return {
  factory = function()
    return T.checkFuntainerFactory(function(cb)
      return f(0, cb)
    end)
  end,
  funtainerarg = function()
    return T.checkFuntainer(T.retn(1, f(0, f(0, function() end))))
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
