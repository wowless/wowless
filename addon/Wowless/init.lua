local function quote(v)
  return type(v) == 'string' and string.format('%q', v) or tostring(v)
end

local function assertEquals(expected, actual)
  if expected ~= actual then
    error(string.format('want %s, got %s', quote(expected), quote(actual)))
  end
end

local export = {
  assertEquals = assertEquals,
}

for k, v in pairs(export) do
  _G[k] = v
end
