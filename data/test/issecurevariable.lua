local T, issecurevariable = ...
local usage = 'Usage: issecurevariable([table,] "variable")'
return {
  ['fails with nil table'] = function()
    return T.match(2, false, usage, pcall(issecurevariable, nil, 'moo'))
  end,
  ['fails with nil variable name'] = function()
    return T.match(2, false, usage, pcall(issecurevariable, nil))
  end,
  ['global wow apis are secure'] = function()
    return T.match(2, true, nil, issecurevariable('issecurevariable'))
  end,
  ['local table values are insecure'] = function()
    return T.match(2, false, T.addonName, issecurevariable(T, 'match'))
  end,
  ['local table values from loadstring are insecure'] = function()
    local taint = '*** ForceTaint_Strong ***'
    return T.match(2, false, taint, issecurevariable({ foo = 42 }, 'foo'))
  end,
  ['missing globals are secure'] = function()
    local k = 'thisisdefinitelynotaglobal'
    T.assertEquals(nil, T.env[k])
    return T.match(2, true, nil, issecurevariable(k))
  end,
  ['missing keys on insecure tables are secure'] = function()
    return T.match(2, true, nil, issecurevariable({}, 'moo'))
  end,
  ['namespaced wow apis are secure'] = function()
    return T.match(2, true, nil, issecurevariable(T.env.C_Timer, 'NewTicker'))
  end,
}
