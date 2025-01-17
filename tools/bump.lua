local tactbuild = require('tactless').build
local yaml = require('wowapi.yaml')
local allProducts = require('runtime.products')
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
  b.hash = assert(tactbuild(p))
  local new = yaml.pprint(b)
  if old ~= new then
    require('pl.file').write(fn, new)
  end
end
