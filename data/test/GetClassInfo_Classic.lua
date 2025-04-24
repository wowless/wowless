local T = ...
return T.wowless and T.wowless.lite and {}
  or {
    hugeneg = function()
      return T.match(3, 'Warrior', 'WARRIOR', 1, T.env.GetClassInfo(-10000))
    end,
    hugepos = function()
      return T.match(0, T.env.GetClassInfo(10000))
    end,
    warrior = function()
      return T.match(3, 'Warrior', 'WARRIOR', 1, T.env.GetClassInfo(1))
    end,
  }
