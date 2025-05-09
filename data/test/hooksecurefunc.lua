local T = ...
return {
  ['hooks members and returns original'] = function()
    local log = {}
    local func = function(a, b, c)
      table.insert(log, string.format('func(%d,%d,%d)', a, b, c))
      return a + 1, b + 1, c + 1
    end
    local hook = function(a, b, c)
      table.insert(log, string.format('hook(%d,%d,%d)', a, b, c))
      return a - 1, b - 1, c - 1
    end
    local t = { member = func }
    T.check0(T.env.hooksecurefunc(t, 'member', hook))
    assert(t.member ~= func)
    assert(t.member ~= hook)
    T.check3(13, 35, 57, t.member(12, 34, 56))
    T.assertEquals('func(12,34,56);hook(12,34,56)', table.concat(log, ';'))
  end,
  ['unpacks nils'] = function()
    local func = function()
      return nil, 42, nil, nil
    end
    local hookWasCalled = false
    local hook = function()
      hookWasCalled = true
    end
    local env = { moocow = func }
    T.check0(T.env.hooksecurefunc(env, 'moocow', hook))
    T.check4(nil, 42, nil, nil, env.moocow())
    assert(hookWasCalled)
  end,
}
