local filename = unpack(arg)
local data
do
  local env = {}
  setfenv(loadfile(filename), env)()
  data = assert(env.WowlessLastTestFailures, 'missing WowlessLastTestFailures')
end
local warnings = assert(data.LUA_WARNING, 'missing LUA_WARNING')
local function tablify(a)
  local t = {}
  for _, v in pairs(a) do
    t[v.warnText] = true
  end
  return t
end
local expected = tablify(warnings.expected)
local actual = tablify(warnings.actual)
local function sub(a, b)
  local t = {}
  for k in pairs(a) do
    if not b[k] then
      t[k] = {}
    end
  end
  return t
end
print(require('wowapi.yaml').pprint({
  extra = sub(expected, actual),
  missing = sub(actual, expected),
}))
