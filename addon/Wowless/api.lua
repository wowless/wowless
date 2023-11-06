local _, G = ...
local assertEquals = _G.assertEquals
local function mainline(x)
  return _G.WowlessData.Build.flavor == 'Mainline' and x or nil
end
local islite = _G.__wowless and _G.__wowless.lite
local function numkeys(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end
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
    C_CovenantSanctumUI = mainline(function()
      return {
        GetRenownLevels = function()
          local function check(...)
            assertEquals(1, select('#', ...))
            local t = ...
            assertEquals('table', type(t))
            assertEquals(nil, getmetatable(t))
            return t
          end
          local tests = {
            ['nil'] = function()
              assert(not pcall(C_CovenantSanctumUI.GetRenownLevels))
            end,
            ['5'] = function()
              local t = check(C_CovenantSanctumUI.GetRenownLevels(5))
              assertEquals(nil, next(t))
            end,
          }
          for i = 1, 4 do
            tests[tostring(i)] = function()
              local t = check(C_CovenantSanctumUI.GetRenownLevels(i))
              assertEquals(islite and 0 or 80, #t)
              assertEquals(islite and 0 or 80, numkeys(t))
              local tt = {}
              for j, v in ipairs(t) do
                tt[tostring(j)] = function()
                  assertEquals('table', type(v))
                  assertEquals(nil, getmetatable(v))
                  assertEquals(4, numkeys(v))
                  assertEquals('boolean', type(v.isCapstone))
                  assertEquals('boolean', type(v.isMilestone))
                  assertEquals('number', type(v.level))
                  assertEquals('boolean', type(v.locked))
                  assertEquals(j, v.level)
                end
              end
              return tt
            end
          end
          return tests
        end,
      }
    end),
    C_Timer = function()
      return {
        NewTicker = function()
          local t = G.retn(1, _G.C_Timer.NewTicker(0, function() end, 0))
          assertEquals('userdata', type(t))
          local mt = getmetatable(t)
          assertEquals('boolean', type(mt))
          assertEquals(false, mt)
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
    GetClickFrame = function()
      local name = 'WowlessGetClickFrameTestFrame'
      local frame = CreateFrame('Frame', name)
      assertEquals(frame, _G.GetClickFrame(name))
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
    IsLinuxClient = function()
      local v = G.retn(1, _G.IsLinuxClient())
      assert(v == true or v == false)
    end,
    IsMacClient = function()
      local v = G.retn(1, _G.IsMacClient())
      assert(v == true or v == false)
    end,
    issecurevariable = function()
      return {
        ['fails with nil table'] = function()
          assertEquals(false, (pcall(issecurevariable, nil, 'moo')))
        end,
        ['fails with nil variable name'] = function()
          assertEquals(false, (pcall(issecurevariable, nil)))
        end,
        ['global wow apis are secure'] = function()
          G.check2(true, nil, issecurevariable('issecurevariable'))
        end,
        ['missing globals are secure'] = function()
          local k = 'thisisdefinitelynotaglobal'
          assertEquals(nil, _G[k])
          G.check2(true, nil, issecurevariable(k))
        end,
        ['missing keys on insecure tables are secure'] = function()
          G.check2(true, nil, issecurevariable({}, 'moo'))
        end,
        ['namespaced wow apis are secure'] = function()
          G.check2(true, nil, issecurevariable(_G.C_Timer, 'NewTicker'))
        end,
      }
    end,
    IsWindowsClient = function()
      local v = G.retn(1, _G.IsWindowsClient())
      assert(v == true or v == false)
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
