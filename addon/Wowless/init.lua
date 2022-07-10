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

local export = {
  assertEquals = assertEquals,
}

for k, v in pairs(export) do
  _G[k] = v
end
