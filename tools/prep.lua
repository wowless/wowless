local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  return parser:parse()
end)()
local alldata = require('wowapi.data')
local function loadApis(product)
  local cfg = require('wowapi.yaml').parseFile('data/products/' .. product .. '/apis.yaml')
  local apis = {}
  for name, apiname in pairs(cfg) do
    local api = alldata.apis[apiname]
    if not api.debug then
      apis[name] = api
    end
  end
  return apis
end
local data = { apis = loadApis(args.product) }
local txt = 'return ' .. require('pl.pretty').write(data)
require('pl.file').write('build/products/' .. args.product .. '/data.lua', txt)
