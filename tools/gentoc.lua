local yaml = require('wowapi.yaml')
local products = require('runtime.products')
local path = require('path')
local pfile = require('pl.file')
local sorted = require('pl.tablex').sort
local args = (function()
  local parser = require('argparse')()
  parser:argument('output', 'generated toc file, or stamp file with --tocprecedence')
  parser:argument('files', 'files of a simple addon; omit for the Wowless addon'):args('*')
  parser:option('--tocprecedence', 'directory to write toc precedence test addons into')
  return parser:parse()
end)()

local interfaces = {}
local gametypes = {}
local familynames = {}
local gametypenames = {}
for _, product in ipairs(products) do
  local build = yaml.parse(pfile.read('data/products/' .. product .. '/build.yaml'))
  local toccfg = yaml.parse(pfile.read('data/products/' .. product .. '/config.yaml')).toc
  interfaces[build.tocversion] = true
  familynames[toccfg.family] = true
  gametypenames[toccfg.gametype] = true
  gametypes[toccfg.family:lower()] = true
  gametypes[toccfg.gametype:lower()] = true
  if toccfg.gametypealias then
    gametypes[toccfg.gametypealias] = true
  end
  for k in pairs(toccfg.excludedgametypes) do
    gametypes[k] = true
  end
end

-- gametype names every product is asserted to treat as unknown; must stay
-- in sync with tools/gentest.lua
for _, k in ipairs({ 'bcc', 'nonsensegametype', 'wowlabs' }) do
  gametypes[k] = true
end

local dir = path.dirname(args.output)

local interfacestrs = {}
for v in sorted(interfaces) do
  table.insert(interfacestrs, tostring(v))
end

if args.tocprecedence then
  -- One addon per pair of toc filename categories, each holding only that
  -- pair's tocs for every product's family and gametype names. Each toc
  -- names its category in X-TocCategory, so GetAddOnMetadata reports which
  -- toc the client chose.
  for name in pairs(familynames) do
    assert(not gametypenames[name], name .. ' is both a family and a gametype')
  end
  local categories = {
    Bare = { [''] = true },
    FamilyDash = {},
    FamilyUnderscore = {},
    GameDash = {},
    GameUnderscore = {},
  }
  for name in pairs(familynames) do
    categories.FamilyDash['-' .. name] = true
    categories.FamilyUnderscore['_' .. name] = true
  end
  for name in pairs(gametypenames) do
    categories.GameDash['-' .. name] = true
    categories.GameUnderscore['_' .. name] = true
  end
  for a in sorted(categories) do
    for b in sorted(categories) do
      if a < b then
        local addon = 'WowlessToc' .. a .. b
        local addondir = path.join(args.tocprecedence, addon)
        path.mkdir(addondir)
        for _, category in ipairs({ a, b }) do
          for suffix in pairs(categories[category]) do
            local lines = {
              '## Interface: ' .. table.concat(interfacestrs, ', '),
              '## X-TocCategory: ' .. category,
              '',
            }
            pfile.write(path.join(addondir, addon .. suffix .. '.toc'), table.concat(lines, '\n'))
          end
        end
      end
    end
  end
  pfile.write(args.output, '')
  return
end

if #args.files > 0 then
  local lines = { '## Interface: ' .. table.concat(interfacestrs, ', ') }
  for _, f in ipairs(args.files) do
    table.insert(lines, f)
  end
  table.insert(lines, '')
  pfile.write(args.output, table.concat(lines, '\n'))
  return
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
