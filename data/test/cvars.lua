local T, GetCVar, GetCVarBool, SetCVar = ...
return {
  bad = function()
    local v = 'WowlessNonsenseCVar'
    T.check1(nil, GetCVar(v))
    T.check1(nil, GetCVarBool(v))
    T.check0(SetCVar(v, '1'))
    T.check1(nil, GetCVar(v))
    T.check1(nil, GetCVarBool(v))
  end,
  good = function()
    local v = 'DebugTorsoTwist'
    T.check1('0', GetCVar(v))
    T.check1(false, GetCVarBool(v))
    T.check1(true, SetCVar(v, '1'))
    T.check1('1', GetCVar(v))
    T.check1(true, GetCVarBool(v))
    T.check1(true, SetCVar(v, '1'))
    T.check1(true, SetCVar(v, '0'))
    T.check1('0', GetCVar(v))
    T.check1(false, GetCVarBool(v))
  end,
}
