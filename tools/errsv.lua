local product, filename = unpack(arg)

local data
do
  local env = {}
  setfenv(loadfile(filename), env)()
  data = env.WowlessLastTestFailures
end

local gf = 'data/globals/' .. product .. '.yaml'
local y = require('wowapi.yaml')
local g = y.parseFile(gf)

for k, v in pairs(data.generated.globals) do
  if k ~= 'Constants' and k ~= 'Enum' then
    local want, got = v:match('want (%d+), got (%d+)')
    if want then
      g[k] = tonumber(got)
    end
  end
end

require('pl.file').write(gf, y.pprint(g))
