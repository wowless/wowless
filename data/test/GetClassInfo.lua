local T, GetClassInfo = ...
return T.wowless and T.wowless.lite and {}
  or {
    hugeneg = function()
      return T.match(0, GetClassInfo(10000))
    end,
    hugepos = function()
      return T.match(0, GetClassInfo(10000))
    end,
    warrior = function()
      return T.match(3, 'Warrior', 'WARRIOR', 1, GetClassInfo(1))
    end,
  }
