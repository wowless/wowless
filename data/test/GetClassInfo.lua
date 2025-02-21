local T = ...
return T.wowless and T.wowless.lite and {}
  or {
    hugeneg = function()
      T.retn(0, T.env.GetClassInfo(10000))
    end,
    hugepos = function()
      T.retn(0, T.env.GetClassInfo(10000))
    end,
    warrior = function()
      T.check3('Warrior', 'WARRIOR', 1, T.env.GetClassInfo(1))
    end,
  }
