local casc = require('casc')
local yaml = require('wowapi.yaml')
local allProducts = require('build.data.products')
local args = (function()
  local parser = require('argparse')()
  parser:argument('products', 'product tags'):args('*'):choices(allProducts)
  return parser:parse()
end)()
local products = next(args.products) and args.products or allProducts
for _, p in ipairs(products) do
  local fn = 'data/products/' .. p .. '/build.yaml'
  local old = require('pl.file').read(fn)
  local b = yaml.parse(old)
  local bkey, _, _, version = casc.cdnbuild('http://us.patch.battle.net:1119/' .. p, 'us')
  local v1, v2, v3, v4 = version:match('^(%d+)%.(%d+)%.(%d+)%.(%d+)$')
  b.build = v4
  b.hash = bkey
  b.version = ('%s.%s.%s'):format(v1, v2, v3)
  b.tocversion = tonumber(v1) * 10000 + tonumber(v2) * 100 + tonumber(v3)
  local new = yaml.pprint(b)
  if old ~= new then
    require('pl.file').write(fn, new)
  end
end
