local deps = {}

local function readfile(f)
  deps[f] = true
  return assert((require('pl.file').read(f)))
end

local function readyaml(f)
  return require('wowapi.yaml').parse(readfile(f))
end

local args = (function()
  local parser = require('argparse')()
  parser:argument('output')
  return parser:parse()
end)()

local names = {}
for name in pairs(readyaml('data/scripttypes.yaml')) do
  table.insert(names, name)
end
table.sort(names)

local scripts = {}
for _, name in ipairs(names) do
  table.insert(scripts, ('      <%s>end, table.insert(WowlessLog, \'%s\')--</%s>'):format(name, name, name))
end

local content = table.concat({
  '<Ui>',
  '  <!-- Actors support scripts through XML even though they aren\'t ScriptObjects. -->',
  '  <Script>',
  '    WowlessLog = {}',
  '  </Script>',
  '  <Actor name=\'WowlessActorTemplate\' virtual=\'true\'>',
  '    <Scripts>',
  table.concat(scripts, '\n'),
  '    </Scripts>',
  '  </Actor>',
  '  <Script>',
  '    CreateFrame(\'ModelScene\'):CreateActor(nil, \'WowlessActorTemplate\')',
  '    local expected = {}',
  '    for k, v in _G.Wowless.sorted(_G.WowlessData.UIObjectApis.Actor.scripts) do',
  '      if v then',
  '        table.insert(expected, k)',
  '      else',
  '        local fmt = \'Frame ModelSceneActor: Unknown script element %s\'',
  '        table.insert(_G.Wowless.ExpectedLuaWarnings, fmt:format(k))',
  '      end',
  '    end',
  '    assertEquals(table.concat(expected, \',\'), table.concat(WowlessLog, \',\'))',
  '  </Script>',
  '</Ui>',
  '',
}, '\n')

require('pl.file').write(args.output, content)
require('tools.util').writedeps(args.output, deps)
