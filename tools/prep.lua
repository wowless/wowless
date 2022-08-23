local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  return parser:parse()
end)()

local product = args.product
local parseYaml = require('wowapi.yaml').parseFile

local data = {
  apis = (function()
    local cfg = parseYaml('data/products/' .. product .. '/apis.yaml')
    local apis = {}
    for name, apiname in pairs(cfg) do
      local apicfg = parseYaml('data/api/' .. apiname .. '.yaml')
      if not apicfg.debug then
        apis[name] = apicfg
      end
    end
    return apis
  end)(),
  build = parseYaml('data/products/' .. product .. '/build.yaml'),
  cvars = parseYaml('data/products/' .. product .. '/cvars.yaml'),
  globals = parseYaml('data/products/' .. product .. '/globals.yaml'),
}
local txt = 'return ' .. require('pl.pretty').write(data)
require('pl.file').write('build/products/' .. args.product .. '/data.lua', txt)
