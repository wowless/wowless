local T, GetClassInfo_Classic = ...
return T.wowless and T.wowless.lite and {}
  or {
    hugeneg = function()
      return T.match(3, 'Warrior', 'WARRIOR', 1, GetClassInfo_Classic(-10000))
    end,
    hugepos = function()
      return T.match(0, GetClassInfo_Classic(10000))
    end,
    warrior = function()
      return T.match(3, 'Warrior', 'WARRIOR', 1, GetClassInfo_Classic(1))
    end,
  }
