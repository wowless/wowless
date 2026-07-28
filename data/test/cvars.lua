local T, GetCVar, SetCVar = ...
return {
  bad = function()
    local v = 'WowlessNonsenseCVar'
    T.check1(nil, GetCVar(v))
    T.check0(SetCVar(v, '1'))
    T.check1(nil, GetCVar(v))
  end,
  good = function()
    local v = 'DebugTorsoTwist'
    T.check1('0', GetCVar(v))
    T.check1(true, SetCVar(v, '1'))
    T.check1('1', GetCVar(v))
    T.check1(true, SetCVar(v, '0'))
    T.check1('0', GetCVar(v))
  end,
}
