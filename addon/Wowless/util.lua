local _, G = ...

local function quote(v)
  return type(v) == 'string' and string.format('%q', v) or tostring(v)
end

local function assertEquals(expected, actual)
  local check = expected == actual
  if type(expected) == 'number' and type(actual) == 'number' then
    check = abs(expected - actual) < 0.0001
  end
  if not check then
    error(string.format('want %s, got %s', quote(expected), quote(actual)), 2)
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

G.assertEquals = assertEquals
G.assertRecursivelyEqual = assertRecursivelyEqual
