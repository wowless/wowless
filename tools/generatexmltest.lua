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
local stringenums = readyaml('data/products/wow/stringenums.yaml')

local function hack(s)
  return 'end,(function()' .. s .. ' end)()--'
end

local function luaLiteral(v)
  if type(v) == 'string' then
    return ('%q'):format(v)
  end
  return tostring(v)
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
          text = hack(('table.insert(WowlessLog, %q)'):format(name)),
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
    {
      tag = 'Layers',
      (function()
        local function fontString(justify, point)
          return {
            tag = 'FontString',
            justifyH = justify,
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
        end
        local layer = { tag = 'Layer', fontString(nil, 'CENTER') }
        for name in sorted(stringenums.JustifyHorizontal) do
          table.insert(layer, fontString(name, name))
          table.insert(layer, fontString(name:lower(), name))
        end
        return layer
      end)(),
    },
  },
  (function()
    -- KeyValue/attribute type coercion cases, one row per key: the raw XML
    -- value/type attrs and the value they should coerce to (see
    -- parseTypedValue in wowless/modules/loader.lua). The 'global' type is
    -- covered elsewhere.
    local kvCases = {
      { key = 'knilstr', value = 'str', expected = 'str' },
      { key = 'knilnum', value = '42', expected = '42' },
      { key = 'knilbool', value = 'true', expected = 'true' },
      { key = 'kstrstr', value = 'str', type = 'string', expected = 'str' },
      { key = 'kstrnum', value = '42', type = 'string', expected = '42' },
      { key = 'kstrbool', value = 'true', type = 'string', expected = 'true' },
      { key = 'knumstr', value = 'str', type = 'number', expected = 0 },
      { key = 'knumnum', value = '42', type = 'number', expected = 42 },
      { key = 'knumbool', value = 'true', type = 'number', expected = 0 },
      { key = 'kjunkstr', value = 'str', type = 'wat', expected = 'str' },
      { key = 'kjunknum', value = '42', type = 'wat', expected = '42' },
      { key = 'kjunkbool', value = 'true', type = 'wat', expected = 'true' },
      { key = 'kboolstr', value = 'str', type = 'boolean', expected = false },
      { key = 'kboolnum', value = '42', type = 'boolean', expected = true },
      { key = 'kboolbool', value = 'true', type = 'boolean', expected = true },
      { key = 'kboolzero', value = '0', type = 'boolean', expected = false },
    }
    local keyvalues = { tag = 'KeyValues' }
    local lines = {}
    for _, c in ipairs(kvCases) do
      table.insert(keyvalues, { tag = 'KeyValue', key = c.key, value = c.value, type = c.type })
      table.insert(lines, ('assertEquals(%s, self.%s)'):format(luaLiteral(c.expected), c.key))
    end
    return {
      tag = 'Frame',
      keyvalues,
      { tag = 'Scripts', { tag = 'OnLoad', text = table.concat(lines, '\n') } },
    }
  end)(),
  (function()
    -- fillStyle is a global Enum in some products and a stringenum in
    -- others. Accumulate every value seen for either representation across
    -- all products, then test each one against whichever representation
    -- the currently running product actually has (Enum.StatusBarFillStyle
    -- is a real global either way, present or absent, so this needs no
    -- wowless-specific data and works unmodified on a real client too).
    local candidates, enumMatch, stringenumMatch = {}, {}, {}
    for _, product in ipairs(readyaml('data/products.yaml')) do
      local fsEnum = readyaml('data/products/' .. product .. '/globals.yaml').Enum.StatusBarFillStyle
      for k, n in pairs(fsEnum or {}) do
        candidates[k] = true
        enumMatch[k:upper()] = n
      end
      local fsStringenum = readyaml('data/products/' .. product .. '/stringenums.yaml').StatusBarFillStyle
      for k in pairs(fsStringenum or {}) do
        candidates[k] = true
        stringenumMatch[k:upper()] = k
      end
    end
    local function fillStyleBar(value)
      local upper = value:upper()
      return {
        tag = 'StatusBar',
        fillStyle = value,
        {
          tag = 'Scripts',
          {
            tag = 'OnLoad',
            text = ([[
              local expected
              if Enum.StatusBarFillStyle then
                expected = %s
              else
                expected = %s
              end
              if expected == nil then
                expected = _G.WowlessFillStyleDefault
              end
              assertEquals(expected, self:GetFillStyle())
            ]]):format(luaLiteral(enumMatch[upper]), luaLiteral(stringenumMatch[upper])),
          },
        },
      }
    end
    local frames = {
      tag = 'Frames',
      {
        tag = 'StatusBar',
        {
          tag = 'Scripts',
          { tag = 'OnLoad', text = '_G.WowlessFillStyleDefault = self:GetFillStyle()' },
        },
      },
    }
    for value in sorted(candidates) do
      table.insert(frames, fillStyleBar(value))
    end
    return { tag = 'Frame', frames }
  end)(),
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
