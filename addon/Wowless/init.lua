local function assertEquals(expected, actual)
  if expected ~= actual then
    error(string.format('want %s, got %s', tostring(expected), tostring(actual)), 2)
  end
end

local export = {
  assertEquals = assertEquals,
}

for k, v in pairs(export) do
  _G[k] = v
end
