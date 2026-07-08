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

local sorted = require('pl.tablex').sort
local scripttypes = readyaml('data/scripttypes.yaml')
local justifyh = readyaml('data/stringenums.yaml').JustifyHorizontal

local function titlecase(name)
  return name:sub(1, 1) .. name:sub(2):lower()
end

local content = {
  tag = 'Ui',
  {
    tag = 'Script',
    text = 'WowlessLog = {}',
  },
  {
    tag = 'Actor',
    name = 'WowlessActorTemplate',
    virtual = true,
    (function()
      local scripts = { tag = 'Scripts' }
      for name in sorted(scripttypes) do
        table.insert(scripts, {
          tag = name,
          text = ([[end, table.insert(WowlessLog, '%s')--]]):format(name),
        })
      end
      return scripts
    end)(),
  },
  {
    tag = 'Script',
    text = [[
      CreateFrame('ModelScene'):CreateActor(nil, 'WowlessActorTemplate')
      local expected = {}
      for k, v in _G.Wowless.sorted(_G.WowlessData.UIObjectApis.Actor.scripts) do
        if v then
          table.insert(expected, k)
        else
          local fmt = 'Frame ModelSceneActor: Unknown script element %s'
          table.insert(_G.Wowless.ExpectedLuaWarnings, fmt:format(k))
        end
      end
      assertEquals(table.concat(expected, ','), table.concat(WowlessLog, ','))
    ]],
  },
  {
    tag = 'Frame',
    (function()
      local layer = { tag = 'Layer' }
      table.insert(layer, { tag = 'FontString', parentKey = 'hNone' })
      for name in sorted(justifyh) do
        table.insert(layer, {
          tag = 'FontString',
          parentKey = 'h' .. titlecase(name),
          justifyH = name,
        })
      end
      return { tag = 'Layers', layer }
    end)(),
    (function()
      local checks = {
        'Wowless.check1(1, self.hNone:GetNumPoints())',
        'Wowless.check5(\'CENTER\', self, \'CENTER\', 0, 0, self.hNone:GetPoint(1))',
      }
      for name in sorted(justifyh) do
        local key = 'h' .. titlecase(name)
        table.insert(checks, ('Wowless.check1(1, self.%s:GetNumPoints())'):format(key))
        table.insert(
          checks,
          ('Wowless.check5(\'%s\', self, \'%s\', 0, 0, self.%s:GetPoint(1))'):format(name, name, key)
        )
      end
      return {
        tag = 'Scripts',
        { tag = 'OnLoad', text = table.concat(checks, '\n') },
      }
    end)(),
  },
}

local renderXml
do
  local function doRenderXml(x, n, t)
    local tt = { (' '):rep(n), '<', x.tag }
    local attrs = {}
    for k, v in pairs(x) do
      if type(k) == 'string' and k ~= 'tag' and k ~= 'text' then
        attrs[k] = v
      end
    end
    for k, v in sorted(attrs) do
      table.insert(tt, (' %s=\'%s\''):format(k, tostring(v)))
    end
    table.insert(tt, '>')
    if x.text then
      table.insert(tt, x.text)
      table.insert(tt, '</')
      table.insert(tt, x.tag)
      table.insert(tt, '>')
      table.insert(t, table.concat(tt))
    else
      table.insert(t, table.concat(tt))
      for _, v in ipairs(x) do
        doRenderXml(v, n + 2, t)
      end
      table.insert(t, table.concat({ (' '):rep(n), '</', x.tag, '>' }))
    end
  end
  function renderXml(x)
    local t = {}
    doRenderXml(x, 0, t)
    return table.concat(t, '\n')
  end
end

require('pl.file').write(args.output, renderXml(content))
require('tools.util').writedeps(args.output, deps)
