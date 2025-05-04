local _, G = ...
local assertEquals = _G.assertEquals
G.testsuite.api = function()
  return {
    C_AreaPoiInfo = function()
      return {
        GetAreaPOIInfo = function()
          -- TODO a real test; this just asserts it is callable
          _G.C_AreaPoiInfo.GetAreaPOIInfo(1, 1)
        end,
      }
    end,
    error = function()
      return {
        nullary = function()
          local success, msg = pcall(error)
          assertEquals(false, success)
          assertEquals(nil, msg)
        end,
        unary = function()
          local success, msg = pcall(error, 'moo')
          assertEquals(false, success)
          assertEquals('moo', msg)
        end,
      }
    end,
    hooksecurefunc = function()
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
          G.check0(hooksecurefunc(t, 'member', hook))
          assert(t.member ~= func)
          assert(t.member ~= hook)
          G.check3(13, 35, 57, t.member(12, 34, 56))
          assertEquals('func(12,34,56);hook(12,34,56)', table.concat(log, ';'))
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
          hooksecurefunc(env, 'moocow', hook)
          G.check4(nil, 42, nil, nil, env.moocow())
          assert(hookWasCalled)
        end,
      }
    end,
    Is64BitClient = function()
      local v = G.retn(1, _G.Is64BitClient())
      assert(v == true or v == false)
    end,
    IsGMClient = function()
      G.check1(false, _G.IsGMClient())
    end,
    loadstring = function()
      return {
        globalenv = function()
          local _G = _G
          setfenv(1, {})
          _G.assertEquals(_G, _G.getfenv(_G.loadstring('')))
        end,
      }
    end,
    secureexecuterange = function()
      return {
        empty = function()
          G.check0(secureexecuterange({}, error))
        end,
        nonempty = function()
          local log = {}
          G.check0(secureexecuterange({ 'foo', 'bar' }, function(...)
            table.insert(log, '[')
            for i = 1, select('#', ...) do
              table.insert(log, (select(i, ...)))
            end
            table.insert(log, ']')
          end, 'baz', 'quux'))
          assertEquals('[,1,foo,baz,quux,],[,2,bar,baz,quux,]', table.concat(log, ','))
        end,
      }
    end,
    table = function()
      return {
        wipe = function()
          local t = { 1, 2, 3 }
          G.check1(t, table.wipe(t))
          assertEquals(nil, next(t))
        end,
      }
    end,
  }
end
