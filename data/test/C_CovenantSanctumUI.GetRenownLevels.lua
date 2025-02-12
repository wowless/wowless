local T = ...
local assertEquals = T.assertEquals
local function numkeys(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end
local islite = T.wowless and T.wowless.lite
local function check(...)
  assertEquals(1, select('#', ...))
  local t = ...
  assertEquals('table', type(t))
  assertEquals(nil, getmetatable(t))
  return t
end
local tests = {
  ['nil'] = function()
    assert(not pcall(T.env.C_CovenantSanctumUI.GetRenownLevels))
  end,
  ['5'] = function()
    local t = check(T.env.C_CovenantSanctumUI.GetRenownLevels(5))
    assertEquals(nil, next(t))
  end,
}
for i = 1, 4 do
  tests[tostring(i)] = function()
    local t = check(T.env.C_CovenantSanctumUI.GetRenownLevels(i))
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
