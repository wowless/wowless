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
local function apiTests()
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
G.ApiTests = apiTests
