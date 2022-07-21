local product, filename = unpack(arg)

local data
do
  local env = {}
  setfenv(loadfile(filename), env)()
  data = env.WowlessLastTestFailures
end

local yaml = require('wowapi.yaml')
local write = require('pl.file').write

do
  local gf = 'data/globals/' .. product .. '.yaml'
  local g = yaml.parseFile(gf)
  for k, v in pairs(data.generated.globals) do
    if k ~= 'Constants' and k ~= 'Enum' then
      local want, got = v:match('want (%d+), got (%d+)')
      if want then
        g[k] = tonumber(got)
      end
    end
  end
  write(gf, yaml.pprint(g))
end

for k, v in pairs(data.generated.uiobjects) do
  if v.methods then
    local uf = 'data/uiobjects/' .. k .. '/' .. k .. '.yaml'
    local u = yaml.parseFile(uf)
    for mk, mv in pairs(v.methods) do
      if mv:match(': missing$') or mv:match(': product disabled: want "nil", got "function"') then
        local m = u.methods[mk]
        if not m then
          m = { products = {}, status = 'unimplemented' }
          u.methods[mk] = m
        end
        assert(m.products)
        local match = false
        for _, p in ipairs(m.products) do
          match = match or p == product
        end
        if not match then
          table.insert(m.products, product)
        end
        table.sort(m.products)
      end
    end
    write(uf, yaml.pprint(u))
  end
end
