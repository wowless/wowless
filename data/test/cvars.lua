local T, GetCVar, GetCVarBool, SetCVar = ...
local updates = {}
local frame = T.env.CreateFrame('Frame')
frame:RegisterEvent('CVAR_UPDATE')
frame:SetScript('OnEvent', function(_, _, ...)
  table.insert(updates, { ... })
end)
return {
  bad = function()
    local v = 'WowlessNonsenseCVar'
    T.check1(nil, GetCVar(v))
    T.check1(nil, GetCVarBool(v))
    T.assertEquals(0, #updates)
    T.check0(SetCVar(v, '1'))
    T.assertEquals(0, #updates)
    T.check1(nil, GetCVar(v))
    T.check1(nil, GetCVarBool(v))
  end,
  good = function()
    local v = 'DebugTorsoTwist'
    T.check1('0', GetCVar(v))
    T.check1(false, GetCVarBool(v))
    T.assertEquals(0, #updates)
    T.check1(true, SetCVar(v, '1'))
    T.assertEquals(1, #updates)
    T.check2(v, '1', unpack(updates[1]))
    updates = {}
    T.check1('1', GetCVar(v))
    T.check1(true, GetCVarBool(v))
    T.check1(true, SetCVar(v, '1'))
    T.assertEquals(0, #updates)
    T.check1(true, SetCVar(v, '0'))
    T.assertEquals(1, #updates)
    T.check2(v, '0', unpack(updates[1]))
    T.check1('0', GetCVar(v))
    T.check1(false, GetCVarBool(v))
  end,
}
