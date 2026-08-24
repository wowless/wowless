local yaml = require('wowapi.yaml')
local products = require('runtime.products')
local args = (function()
  local parser = require('argparse')()
  parser:argument('output', 'generated toc file')
  return parser:parse()
end)()

local seen = {}
local interfaces = {}
for _, product in ipairs(products) do
  local fn = 'data/products/' .. product .. '/build.yaml'
  local build = yaml.parse(require('pl.file').read(fn))
  local v = assert(build.tocversion, fn)
  if not seen[v] then
    seen[v] = true
    table.insert(interfaces, v)
  end
end
table.sort(interfaces)
for i, v in ipairs(interfaces) do
  interfaces[i] = tostring(v)
end

local lines = {
  '## Dependencies: WowlessData',
  '## Interface: ' .. table.concat(interfaces, ', '),
  '## SavedVariables: WowlessLastTestFailures',
  '## Notes: WoW client unit tests',
  '## Title: Wowless',
  'util.lua',
  'init.lua',
  'framework.lua',
  'statemachine.lua',
  'arraydiff.lua',
  'funtainer.lua',
  'luaobjects.lua',
  'test.xml',
  'generated.lua',
  'uiobjects.lua',
  'templates.lua',
  'asynctests.lua',
  'test.lua',
  '',
}
require('pl.file').write(args.output, table.concat(lines, '\n'))
