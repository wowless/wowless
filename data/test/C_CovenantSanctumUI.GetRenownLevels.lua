local T, GetRenownLevels, GetCovenantIDs = ...
local assertEquals = T.assertEquals
local function numkeys(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end
local islite = not not (_G.__wowless and _G.__wowless.lite)
local function check(...)
  assertEquals(1, select('#', ...))
  local t = ...
  assertEquals('table', type(t))
  assertEquals(nil, getmetatable(t))
  return t
end
local covenantIDs = check(GetCovenantIDs())
assertEquals(islite, next(covenantIDs) == nil)
local maxID = 0
for _, id in ipairs(covenantIDs) do
  if id > maxID then
    maxID = id
  end
end
local invalidID = maxID + 1
local tests = {
  ['nil'] = function()
    assert(not pcall(GetRenownLevels))
  end,
  [tostring(invalidID)] = function()
    local t = check(GetRenownLevels(invalidID))
    assertEquals(nil, next(t))
  end,
}
for _, id in ipairs(covenantIDs) do
  tests[tostring(id)] = function()
    local t = check(GetRenownLevels(id))
    assert(#t > 0)
    assertEquals(#t, numkeys(t))
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
      end
    end
    return tt
  end
end
return tests
