local allTypes = { 'apis', 'constants', 'enums', 'events', 'structures' }
local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  parser:argument('type', 'type to write'):choices(allTypes)
  parser:argument('filter', 'name filter'):default('')
  parser:flag('--new', 'add missing objects')
  return parser:parse()
end)()

local lfs = require('lfs')
local writeFile = require('pl.file').write
local pprintYaml = require('wowapi.yaml').pprint
local product = args.product

local function enabled(t, k)
  return k:sub(1, #args.filter) == args.filter and (args.new or t[k])
end

local function deref(t, ...)
  for i = 1, select('#', ...) do
    assert(type(t) == 'table')
    local k = select(i, ...)
    t = t[k]
    if t == nil then
      return nil
    end
  end
  return t
end

local docs = {}
do
  local mixmt = {
    __index = function()
      return function() end
    end,
  }
  local nummt = {
    __index = function()
      return 42
    end,
  }
  local nsmt = {
    __index = function()
      return setmetatable({}, nummt)
    end,
  }
  local schema = require('wowapi.yaml').parseFile('data/schemas/docs.yaml').type
  local function processDocDir(docdir)
    if lfs.attributes(docdir) then
      for f in lfs.dir(docdir) do
        if f:sub(-4) == '.lua' then
          local success, err = pcall(setfenv(loadfile(docdir .. '/' .. f), {
            APIDocumentation = {
              AddDocumentationTable = function(_, t)
                require('wowapi.schema').validate(product, schema, t)
                docs[f] = t
              end,
            },
            Constants = setmetatable({}, nsmt),
            CreateFromMixins = function()
              return setmetatable({}, mixmt)
            end,
            Enum = setmetatable({}, nsmt),
          }))
          if not success then
            print(('error loading %s: %s'):format(f, err))
          end
        end
      end
    end
  end
  local prefix = 'extracts/' .. product .. '/Interface/AddOns/'
  processDocDir(prefix .. 'Blizzard_APIDocumentation')
  processDocDir(prefix .. 'Blizzard_APIDocumentationGenerated')
end

local enum = require('wowapi.yaml').parseFile('data/products/' .. product .. '/globals.yaml').Enum

local tabs, funcs, events = {}, {}, {}
for _, t in pairs(docs) do
  if not t.Type or t.Type == 'System' and t.Namespace ~= 'C_ConfigurationWarnings' then
    for _, tab in ipairs(t.Tables or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. tab.Name
      assert(not tabs[name])
      tabs[name] = tab
    end
    for _, func in ipairs(t.Functions or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. func.Name
      assert(not funcs[name])
      funcs[name] = func
    end
    for _, event in ipairs(t.Events or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. event.Name
      assert(not events[name])
      events[name] = event
    end
  end
end

local types = {
  bool = 'boolean',
  FramePoint = 'string', -- hack, yes
  InventorySlots = 'number',
  number = 'number',
  string = 'string',
  table = 'table',
}
local tys = {}
for name, tab in pairs(tabs) do
  tys[name] = tab.Type
end
for k in pairs(require('wowapi.data').structures[product]) do
  if tys[k] and tys[k] ~= 'Structure' then
    error(('%s is a wowless structure but is a %s in docs'):format(k, tys[k]))
  else
    tys[k] = 'Structure'
  end
end
for k in pairs(enum) do
  if tys[k] and tys[k] ~= 'Enumeration' then
    error(('%s is a wowless enum but is a %s in docs'):format(k, tys[k]))
  else
    tys[k] = 'Enumeration'
  end
end
local knownMixinStructs = {
  ColorMixin = 'Color',
  ItemLocationMixin = 'ItemLocation',
  ItemTransmogInfoMixin = 'ItemTransmogInfo',
  PlayerLocationMixin = 'PlayerLocation',
  ReportInfoMixin = 'ReportInfo',
  TransmogLocationMixin = 'TransmogLocation',
  TransmogPendingInfoMixin = 'TransmogPendingInfo',
  Vector2DMixin = 'Vector2D',
  Vector3DMixin = 'Vector3D',
}
local function t2ty(t, ns, mixin)
  if t == 'table' and mixin then
    return assert(knownMixinStructs[mixin], 'no struct for mixin ' .. mixin), true
  elseif types[t] then
    return types[t]
  end
  local n = ns and tys[ns .. '.' .. t] and (ns .. '.' .. t) or t
  local ty = tys[n]
  assert(ty, 'wtf ' .. n)
  if ty == 'Enumeration' or ty == 'Constants' then
    return 'number'
  elseif ty == 'Structure' then
    return n, true
  elseif ty == 'CallbackType' then
    return 'function'
  else
    error(('%s has unexpected type %s'):format(n, ty))
  end
end

local rewriters = {
  apis = function()
    local function insig(fn, ns)
      local t = {}
      for _, a in ipairs(fn.Arguments or {}) do
        table.insert(t, {
          default = a.Default,
          innerType = a.InnerType and t2ty(a.InnerType, ns),
          mixin = a.Mixin,
          name = a.Name,
          nilable = a.Nilable or nil,
          type = t2ty(a.Type, ns, a.Mixin),
        })
      end
      return t
    end
    local function outsig(fn, ns)
      local outputs = {}
      for _, r in ipairs(fn.Returns or {}) do
        table.insert(outputs, {
          default = enum[r.Type] and enum[r.Type][r.Default] or r.Default,
          innerType = r.InnerType and t2ty(r.InnerType, ns),
          mixin = r.Mixin,
          name = r.Name,
          nilable = r.Nilable or nil,
          type = t2ty(r.Type, ns, r.Mixin),
        })
      end
      return outputs
    end
    local function skip(api)
      if not api then
        return false
      end
      if api.impl then
        return true
      end
      for _, out in ipairs(api.outputs or {}) do
        if out.stub then
          return true
        end
      end
      return false
    end
    local y = require('wowapi.yaml')
    local f = 'data/products/' .. product .. '/apis.yaml'
    local apis = y.parseFile(f)
    for name, fn in pairs(funcs) do
      if enabled(apis, name) and not skip(apis[name]) then
        local dotpos = name:find('%.')
        local ns = dotpos and name:sub(1, dotpos - 1)
        apis[name] = {
          inputs = { insig(fn, ns) },
          outputs = outsig(fn, ns),
        }
      end
    end
    require('pl.file').write(f, y.pprint(apis))
  end,

  constants = function()
    local t = {}
    for _, v in pairs(tabs) do
      if v.Type == 'Constants' then
        local vt = {}
        assert(type(v.Values) == 'table')
        for _, fv in ipairs(v.Values) do
          assert(type(fv.Name) == 'string', 'missing name for field of ' .. v.Name)
          -- TODO fv.Type validation
          -- TODO support non-number-literal constants
          vt[fv.Name] = type(fv.Value) == 'number' and fv.Value or 0
        end
        t[v.Name] = vt
      end
    end
    local y = require('wowapi.yaml')
    local f = 'data/products/' .. product .. '/globals.yaml'
    local g = y.parseFile(f)
    for k, v in pairs(t) do
      g.Constants[k] = v
    end
    require('pl.file').write(f, y.pprint(g))
  end,

  enums = function()
    local t = {}
    for _, v in pairs(tabs) do
      if v.Type == 'Enumeration' then
        local vt = {}
        for _, fv in ipairs(v.Fields) do
          assert(fv.Type == v.Name, 'wrong type for ' .. v.Name .. '.' .. fv.Name)
          vt[fv.Name] = fv.EnumValue
        end
        t[v.Name] = vt
        t[v.Name .. 'Meta'] = {
          MaxValue = v.MaxValue,
          MinValue = v.MinValue,
          NumValues = v.NumValues,
        }
      end
    end
    local y = require('wowapi.yaml')
    local f = 'data/products/' .. product .. '/globals.yaml'
    local g = y.parseFile(f)
    for k, v in pairs(t) do
      g.Enum[k] = v
    end
    require('pl.file').write(f, y.pprint(g))
  end,

  events = function()
    local filename = ('data/products/%s/events.yaml'):format(product)
    local out = require('wowapi.yaml').parseFile(filename)
    for name, ev in pairs(events) do
      local dotpos = name:find('%.')
      local ns = dotpos and name:sub(1, dotpos - 1)
      local value = {
        payload = (function()
          local t = {}
          for _, arg in ipairs(ev.Payload or {}) do
            table.insert(t, {
              name = arg.Name,
              nilable = arg.Nilable or nil,
              type = (function()
                if arg.InnerType then
                  return { arrayof = t2ty(arg.InnerType, ns) }
                end
                local ty, isstruct = t2ty(arg.Type, ns, arg.Mixin)
                if isstruct then
                  return { mixin = arg.Mixin, structure = ty }
                else
                  return ty
                end
              end)(),
            })
          end
          return t
        end)(),
      }
      local k = ev.LiteralName
      if out[k] and out[k].docsarewrong then
        assert(not require('pl.tablex').deepcompare(out[k].payload, value.payload))
      else
        out[k] = value
      end
    end
    writeFile(filename, pprintYaml(out))
  end,

  structures = function()
    local stubs = {
      FramePoint = 'CENTER',
    }
    local filename = ('data/products/%s/structures.yaml'):format(product)
    local out = require('wowapi.yaml').parseFile(filename)
    for name, tab in pairs(tabs) do
      if tab.Type == 'Structure' and enabled(out, name) then
        local dotpos = name:find('%.')
        local ns = dotpos and name:sub(1, dotpos - 1)
        out[name] = (function()
          local ret = {}
          for _, field in ipairs(tab.Fields) do
            ret[field.Name] = {
              default = field.Default,
              nilable = field.Nilable or nil,
              stub = deref(out, name, field.Name, 'stub') or stubs[field.Type],
              type = (function()
                if field.InnerType then
                  return { arrayof = t2ty(field.InnerType, ns) }
                end
                local ty, isstruct = t2ty(field.Type, ns, field.Mixin)
                if isstruct then
                  return { mixin = field.Mixin, structure = ty }
                else
                  return ty
                end
              end)(),
            }
          end
          return ret
        end)()
      end
    end
    writeFile(filename, pprintYaml(out))
  end,
}

rewriters[args.type]()
