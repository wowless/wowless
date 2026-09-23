local yaml = require('wowapi.yaml')
local products = require('runtime.products')
local path = require('path')
local pfile = require('pl.file')
local sorted = require('pl.tablex').sort
local args = (function()
  local parser = require('argparse')()
  parser:argument('output', 'generated toc file')
  return parser:parse()
end)()

local interfaces = {}
local gametypes = {}
local families = {}
for _, product in ipairs(products) do
  local build = yaml.parse(pfile.read('data/products/' .. product .. '/build.yaml'))
  interfaces[build.tocversion] = true
  gametypes[build.gametype] = true
  families[build.family] = true
end

local dir = path.dirname(args.output)

local interfacestrs = {}
for v in sorted(interfaces) do
  table.insert(interfacestrs, tostring(v))
end

local lines = {
  '## Dependencies: WowlessData',
  '## Interface: ' .. table.concat(interfacestrs, ', '),
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
}
local function addmarkers(field, set)
  for token in sorted(set) do
    local fname = field .. '_' .. token .. '.lua'
    table.insert(lines, ('%s [AllowLoadGameType %s]'):format(fname, token:lower()))
    pfile.write(path.join(dir, fname), ('local _, G = ...\nG.%s[%q] = true\n'):format(field, token))
  end
end
addmarkers('GameTypes', gametypes)
addmarkers('Families', families)
table.insert(lines, '')
pfile.write(args.output, table.concat(lines, '\n'))
