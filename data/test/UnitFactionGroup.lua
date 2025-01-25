local T = ...
return T.wowless and T.wowless.lite and {}
  or {
    player = function()
      T.check2('Horde', 'Horde', T.env.UnitFactionGroup('player'))
    end,
    target = function()
      T.check2(nil, nil, T.env.UnitFactionGroup('target'))
    end,
  }
