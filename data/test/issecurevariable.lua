local T = ...
local usage = 'Usage: issecurevariable([table,] "variable")'
return {
  ['fails with nil table'] = function()
    return T.match(2, false, usage, pcall(T.env.issecurevariable, nil, 'moo'))
  end,
  ['fails with nil variable name'] = function()
    return T.match(2, false, usage, pcall(T.env.issecurevariable, nil))
  end,
  ['global wow apis are secure'] = function()
    return T.match(2, true, nil, T.env.issecurevariable('issecurevariable'))
  end,
  ['local table values are insecure'] = function()
    return T.match(2, false, T.addonName, T.env.issecurevariable(T, 'match'))
  end,
  ['local table values from loadstring are insecure'] = function()
    local taint = '*** ForceTaint_Strong ***'
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
