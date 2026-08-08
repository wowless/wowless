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
-- scripttypes.yaml is per-product (some products dropped script hooks
-- deprecated on other versions -- issue #864); this file isn't, so it
-- unions the full universe across products for maximum coverage, and
-- generatedxml.xml's own comparison logic checks each product's own
-- ScriptTypes data at runtime to expect the right warning either way.
local scripttypes = {}
for _, p in ipairs(readyaml('data/products.yaml')) do
  for name in pairs(readyaml(('data/products/%s/scripttypes.yaml'):format(p))) do
    scripttypes[name] = true
  end
end
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
    text = (function()
      local names = {}
      for name in sorted(scripttypes) do
        table.insert(names, luaLiteral(name))
      end
      -- Iterates the full cross-product name universe (not
      -- UIObjectApis.Actor.scripts, which only has this product's own
      -- valid names -- issue #864) so a name invalid here still gets
      -- classified, not silently skipped.
      return ([[
        CreateFrame('ModelScene'):CreateActor(nil, 'WowlessActorTemplate')
        local allNames = {%s}
        local expected = {}
        for _, k in ipairs(allNames) do
          local v = _G.WowlessData.UIObjectApis.Actor.scripts[k]
          if v then
            table.insert(expected, k)
          elseif _G.WowlessData.ScriptTypes[k] then
            local fmt = 'Frame ModelSceneActor: Unknown script element %%s'
            table.insert(_G.Wowless.ExpectedLuaWarnings, fmt:format(k))
          else
            table.insert(_G.Wowless.ExpectedNextFrame, 'Unrecognized XML: ' .. k)
          end
        end
        assertEquals(table.concat(expected, ','), table.concat(WowlessLog, ','))
      ]]):format(table.concat(names, ','))
    end)(),
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
