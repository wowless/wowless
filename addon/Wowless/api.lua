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
          assert(_G.C_AreaPoiInfo.GetAreaPOIInfo(1, 1), 'doh')
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
  }
end
G.ApiTests = apiTests
