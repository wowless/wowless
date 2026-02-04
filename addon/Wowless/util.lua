local _, G = ...

local function quote(v)
  return type(v) == 'string' and string.format('%q', v) or tostring(v)
end

local function assertEquals(expected, actual, msg, depth)
  local check = expected == actual
  if type(expected) == 'number' and type(actual) == 'number' then
    check = math.abs(expected - actual) < 0.0001
  end
  if not check then
    error(string.format('%swant %s, got %s', msg and msg .. ': ' or '', quote(expected), quote(actual)), depth or 2)
  end
end

local function assertEqualSets(expected, actual)
  for k in pairs(expected) do
    if not actual[k] then
      error(('missing %q'):format(k), 0)
    end
  end
  for k in pairs(actual) do
    if not expected[k] then
      error(('extra %q'):format(k), 0)
    end
  end
end

local function assertRecursivelyEqual(expected, actual)
  local ty = type(expected)
  assertEquals(ty, type(actual))
  if ty == 'table' then
    local t = {}
    for k, v in pairs(expected) do
      t[k] = function()
        return assertRecursivelyEqual(v, actual[k])
      end
    end
    for k, v in pairs(actual) do
      t[k] = t[k] or function()
        error(('missing key %q with value %s'):format(k, tostring(v)))
      end
    end
    return t
  elseif ty == 'string' or ty == 'number' or ty == 'boolean' then
    assertEquals(expected, actual)
  end
end

local function match(k, ...)
  local n = select('#', ...)
  assert(n >= k, 'match usage error: insufficient args')
  local t = {}
  for i = 1, k do
    local expected = select(i, ...)
    local actual = select(k + i, ...)
    t[tostring(i)] = function()
      assert(n >= k + i, 'missing value')
      assertEquals(expected, actual, nil, 3)
    end
  end
  t.extra = function()
    assert(n <= 2 * k, 'too many return values')
  end
  return t
end

local function checkEquals(expected, actual)
  assertEquals(expected, actual, nil, 4)
end

local function check0(...)
  checkEquals(0, select('#', ...))
end

local function check1(e1, ...)
  checkEquals(1, select('#', ...))
  local a1 = ...
  checkEquals(e1, a1)
end

local function check2(e1, e2, ...)
  checkEquals(2, select('#', ...))
  local a1, a2 = ...
  checkEquals(e1, a1)
  checkEquals(e2, a2)
end

local function check3(e1, e2, e3, ...)
  checkEquals(3, select('#', ...))
  local a1, a2, a3 = ...
  checkEquals(e1, a1)
  checkEquals(e2, a2)
  checkEquals(e3, a3)
end

local function check4(e1, e2, e3, e4, ...)
  checkEquals(4, select('#', ...))
  local a1, a2, a3, a4 = ...
  checkEquals(e1, a1)
  checkEquals(e2, a2)
  checkEquals(e3, a3)
  checkEquals(e4, a4)
end

local function check5(e1, e2, e3, e4, e5, ...)
  checkEquals(5, select('#', ...))
  local a1, a2, a3, a4, a5 = ...
  checkEquals(e1, a1)
  checkEquals(e2, a2)
  checkEquals(e3, a3)
  checkEquals(e4, a4)
  checkEquals(e5, a5)
end

local function check6(e1, e2, e3, e4, e5, e6, ...)
  checkEquals(6, select('#', ...))
  local a1, a2, a3, a4, a5, a6 = ...
  checkEquals(e1, a1)
  checkEquals(e2, a2)
  checkEquals(e3, a3)
  checkEquals(e4, a4)
  checkEquals(e5, a5)
  checkEquals(e6, a6)
end

local function check7(e1, e2, e3, e4, e5, e6, e7, ...)
  checkEquals(7, select('#', ...))
  local a1, a2, a3, a4, a5, a6, a7 = ...
  checkEquals(e1, a1)
  checkEquals(e2, a2)
  checkEquals(e3, a3)
  checkEquals(e4, a4)
  checkEquals(e5, a5)
  checkEquals(e6, a6)
  checkEquals(e7, a7)
end

local function retn(n, ...)
  local k = select('#', ...)
  if n ~= k then
    error(string.format('wrong number of return values: want %d, got %d', n, k), 2)
  end
  return ...
end

local function mixin(t, ...)
  for i = 1, select('#', ...) do
    for k, v in pairs(select(i, ...)) do
      t[k] = v
    end
  end
  return t
end

G.addonEnv = G
G.assertEquals = assertEquals
G.assertEqualSets = assertEqualSets
G.assertRecursivelyEqual = assertRecursivelyEqual
G.check0 = check0
G.check1 = check1
G.check2 = check2
G.check3 = check3
G.check4 = check4
G.check5 = check5
G.check6 = check6
G.check7 = check7
G.globalEnv = _G
G.match = match
G.mixin = mixin
G.retn = retn
