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
for _, product in ipairs(products) do
  local build = yaml.parse(pfile.read('data/products/' .. product .. '/build.yaml'))
  interfaces[build.tocversion] = true
  gametypes[build.family:lower()] = true
  gametypes[build.gametype:lower()] = true
  for k in pairs(yaml.parse(pfile.read('data/products/' .. product .. '/excludedgametypes.yaml'))) do
    gametypes[k] = true
  end
end

-- a value no real product declares or excludes, so its marker file must
-- never load
gametypes.nonsensegametype = true

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
  '## X-Family: [Family]',
  '## X-GameType: [Game]',
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
for token in sorted(gametypes) do
  local fname = 'GameTypes_' .. token .. '.lua'
  table.insert(lines, ('%s [AllowLoadGameType %s]'):format(fname, token:lower()))
  pfile.write(path.join(dir, fname), ('local _, G = ...\nG.GameTypes[%q] = true\n'):format(token))
end
table.insert(lines, '')
pfile.write(args.output, table.concat(lines, '\n'))
