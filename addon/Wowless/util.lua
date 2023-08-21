local _, G = ...

local function quote(v)
  return type(v) == 'string' and string.format('%q', v) or tostring(v)
end

local function assertEquals(expected, actual, msg)
  local check = expected == actual
  if type(expected) == 'number' and type(actual) == 'number' then
    check = abs(expected - actual) < 0.0001
  end
  if not check then
    error(string.format('%swant %s, got %s', msg and msg .. ': ' or '', quote(expected), quote(actual)), 2)
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

local function check0(...)
  assertEquals(0, select('#', ...))
end

local function check1(e1, ...)
  assertEquals(1, select('#', ...))
  local a1 = ...
  assertEquals(e1, a1)
end

local function check4(e1, e2, e3, e4, ...)
  assertEquals(4, select('#', ...))
  local a1, a2, a3, a4 = ...
  assertEquals(e1, a1)
  assertEquals(e2, a2)
  assertEquals(e3, a3)
  assertEquals(e4, a4)
end

local function check6(e1, e2, e3, e4, e5, e6, ...)
  assertEquals(6, select('#', ...))
  local a1, a2, a3, a4, a5, a6 = ...
  assertEquals(e1, a1)
  assertEquals(e2, a2)
  assertEquals(e3, a3)
  assertEquals(e4, a4)
  assertEquals(e5, a5)
  assertEquals(e6, a6)
end

local function check7(e1, e2, e3, e4, e5, e6, e7, ...)
  assertEquals(7, select('#', ...))
  local a1, a2, a3, a4, a5, a6, a7 = ...
  assertEquals(e1, a1)
  assertEquals(e2, a2)
  assertEquals(e3, a3)
  assertEquals(e4, a4)
  assertEquals(e5, a5)
  assertEquals(e6, a6)
  assertEquals(e7, a7)
end

local function mixin(t, ...)
  for i = 1, select('#', ...) do
    for k, v in pairs(select(i, ...)) do
      t[k] = v
    end
  end
  return t
end

G.assertEquals = assertEquals
G.assertRecursivelyEqual = assertRecursivelyEqual
G.check0 = check0
G.check1 = check1
G.check4 = check4
G.check6 = check6
G.check7 = check7
G.mixin = mixin
