local T = ...
return {
  ['fails with nil table'] = function()
    T.assertEquals(false, (pcall(T.env.issecurevariable, nil, 'moo')))
  end,
  ['fails with nil variable name'] = function()
    T.assertEquals(false, (pcall(T.env.issecurevariable, nil)))
  end,
  ['global wow apis are secure'] = function()
    return T.match(2, true, nil, T.env.issecurevariable('issecurevariable'))
  end,
  ['local table values are insecure'] = function()
    return T.match(2, false, T.addonName, T.env.issecurevariable(T, 'match'))
  end,
  ['local table values from loadstring are insecure'] = function()
    local taint = T.wowless and T.addonName or '*** ForceTaint_Strong ***' -- issue #411
    return T.match(2, false, taint, T.env.issecurevariable({ foo = 42 }, 'foo'))
  end,
  ['missing globals are secure'] = function()
    local k = 'thisisdefinitelynotaglobal'
    T.assertEquals(nil, T.env[k])
    return T.match(2, true, nil, T.env.issecurevariable(k))
  end,
  ['missing keys on insecure tables are secure'] = function()
    return T.match(2, true, nil, T.env.issecurevariable({}, 'moo'))
  end,
  ['namespaced wow apis are secure'] = function()
    return T.match(2, true, nil, T.env.issecurevariable(T.env.C_Timer, 'NewTicker'))
  end,
}
