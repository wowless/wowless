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

local function actorScripts()
  local t = {}
  for name in sorted(scripttypes) do
    table.insert(t, {
      tag = name,
      text = ([[end, table.insert(WowlessLog, '%s')--]]):format(name),
    })
  end
  return t
end

local function justifyFontString(justify)
  local point = justify or 'CENTER'
  local node = {
    tag = 'FontString',
    {
      tag = 'Scripts',
      {
        tag = 'OnLoad',
        text = ([[
          Wowless.check1(1, self:GetNumPoints())
          Wowless.check5('%s', self:GetParent(), '%s', 0, 0, self:GetPoint(1))
        ]]):format(point, point),
      },
    },
  }
  node.justifyH = justify
  return node
end

local function justifyFontStrings()
  local t = {}
  for name in sorted(justifyh) do
    table.insert(t, justifyFontString(name))
  end
  return t
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
    {
      tag = 'Scripts',
      unpack(actorScripts()),
    },
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
    {
      tag = 'Layers',
      {
        tag = 'Layer',
        justifyFontString(nil),
        unpack(justifyFontStrings()),
      },
    },
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
