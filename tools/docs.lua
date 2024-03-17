local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  return parser:parse()
end)()

local lfs = require('lfs')
local writeifchanged = require('tools.util').writeifchanged
local parseYaml = require('wowapi.yaml').parseFile
local pprintYaml = require('wowapi.yaml').pprint
local product = args.product

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
  local schema = require('wowapi.yaml').parseFile('data/schemas/doctable.yaml').type
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

local config = parseYaml('data/products/' .. product .. '/docs.yaml')
local enum = parseYaml('data/products/' .. product .. '/globals.yaml').Enum

for k in pairs(deref(config, 'skip_docfiles') or {}) do
  local f = k .. '.lua'
  assert(docs[f], 'missing skip_docfiles ' .. f)
  docs[f] = nil
end

local tabs, funcs, events, scrobjs = {}, {}, {}, {}
for _, t in pairs(docs) do
  if not t.Type or t.Type == 'System' then
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
  elseif t.Type == 'ScriptObject' then
    assert(config.script_objects[t.Name], 'missing script object mapping for ' .. t.Name)
    assert(not scrobjs[t.Name])
    scrobjs[t.Name] = t
  end
end

for k in pairs(config.script_objects) do
  assert(scrobjs[k], 'redundant script object mapping ' .. k)
end

local typedefs = config.typedefs or {}
local stringenums = parseYaml('data/stringenums.yaml')
local tys = {}
for name, tab in pairs(tabs) do
  tys[name] = tab.Type
end
local structs = parseYaml('data/products/' .. product .. '/structures.yaml')
for k in pairs(structs) do
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
local structRewrites = {
  AzeriteEmpoweredItemLocation = 'ItemLocation',
  AzeriteItemLocation = 'ItemLocation',
  EmptiableItemLocation = 'ItemLocation',
}
local used_typedefs = {}
local function t2nty(field, ns)
  local t = field.Type
  if field.InnerType then
    assert(t == 'table')
    return { arrayof = t2nty({ Type = field.InnerType }, ns) }
  elseif t == 'table' and field.Mixin then
    error('no struct for mixin ' .. field.Mixin)
  elseif typedefs[t] then
    used_typedefs[t] = true
    return typedefs[t]
  elseif stringenums[t] then
    return t
  end
  local n = ns and tys[ns .. '.' .. t] and (ns .. '.' .. t) or t
  n = structRewrites[n] or n
  local ty = tys[n]
  assert(ty, 'wtf ' .. n)
  if ty == 'Constants' then
    return 'number'
  elseif ty == 'Enumeration' then
    return { enum = t }
  elseif ty == 'Structure' then
    if field.Mixin and field.Mixin ~= structs[n].mixin then
      error(('expected struct %s to have mixin %s'):format(n, field.Mixin))
    end
    return { structure = n }
  elseif ty == 'CallbackType' then
    return field.Name == 'cbObject' and 'userdata' or 'function'
  else
    error(('%s has unexpected type %s'):format(n, ty))
  end
end

local function split(name)
  local dotpos = name:find('%.')
  if not dotpos then
    return nil, name
  else
    return name:sub(1, dotpos - 1), name:sub(dotpos + 1)
  end
end

local function stride(ts)
  local n = 0
  for _, t in ipairs(ts or {}) do
    if t.StrideIndex then
      n = n + 1
      assert(n == t.StrideIndex)
    else
      assert(n == 0)
    end
  end
  return n > 0 and n or nil
end

-- Super duper hack, sorry world.
local unitHacks = {
  UnitFactionGroup = 'unitName',
  UnitName = 'unit',
  UnitIsUnit = 'unitName',
  UnitRace = 'name',
}

local function rewriteApis()
  local function insig(fn, ns)
    local unitHack = unitHacks[fn.Name]
    local t = {}
    for _, a in ipairs(fn.Arguments or {}) do
      if unitHack and a.Name:sub(1, unitHack:len()) == unitHack then
        assert(a.Type == 'cstring')
        assert(not a.Default)
        assert(not a.Nilable)
        table.insert(t, {
          name = a.Name,
          type = 'unit',
        })
      elseif a.Type == 'UnitToken' and a.Default == 'WOWGUID_NULL' then
        table.insert(t, {
          name = a.Name,
          nilable = true,
          type = 'unit',
        })
      else
        table.insert(t, {
          default = enum[a.Type] and enum[a.Type][a.Default] or a.Default,
          name = a.Name,
          nilable = a.Nilable or nil,
          type = t2nty(a, ns),
        })
      end
    end
    return t
  end
  local function outsig(fn, ns, api)
    local stubs = {}
    local stubnotnils = {}
    for _, output in ipairs(api and api.outputs or {}) do
      if output.name then
        stubs[output.name] = output.stub
        stubnotnils[output.name] = output.stubnotnil
      end
    end
    local outputs = {}
    for _, r in ipairs(fn.Returns or {}) do
      local ty = t2nty(r, ns)
      table.insert(outputs, {
        default = enum[r.Type] and enum[r.Type][r.Default] or r.Default,
        name = r.Name,
        nilable = (r.Nilable or fn.Name == 'UnitName') and ty ~= 'nil' or nil, -- horrible hack
        stub = stubs[r.Name],
        stubnotnil = stubnotnils[r.Name],
        type = ty,
      })
      stubs[r.Name] = nil
    end
    if next(stubs) ~= nil then
      error(table.concat({
        'stub merge error on',
        ns and (' ns = ' .. ns) or '',
        '\n',
        require('pl.pretty').write(fn),
      }, ''))
    end
    return outputs
  end
  local y = require('wowapi.yaml')
  local f = 'data/products/' .. product .. '/apis.yaml'
  local apis = y.parseFile(f)
  for name, fn in pairs(funcs) do
    if not deref(config, 'skip_apis', name) then
      local ns = split(name)
      local api = apis[name]
      apis[name] = {
        impl = api and api.impl,
        inputs = insig(fn, ns),
        mayreturnnothing = api and api.mayreturnnothing,
        outputs = outsig(fn, ns, api),
        outstride = stride(fn.Returns),
        stubnothing = api and api.stubnothing,
      }
    end
  end
  writeifchanged(f, y.pprint(apis))
  return apis
end

local function rewriteEvents()
  local filename = ('data/products/%s/events.yaml'):format(product)
  local neversent = deref(config, 'events', 'never_sent') or {}
  local out = require('wowapi.yaml').parseFile(filename)
  local seen = {}
  for name, ev in pairs(events) do
    seen[ev.LiteralName] = true
    local ns = split(name)
    out[ev.LiteralName] = {
      payload = (function()
        if neversent[ev.LiteralName] then
          return nil
        end
        local t = {}
        for _, arg in ipairs(ev.Payload or {}) do
          table.insert(t, {
            name = arg.Name,
            nilable = arg.Nilable or nil,
            type = t2nty(arg, ns),
          })
        end
        return t
      end)(),
    }
  end
  for k in pairs(neversent) do
    assert(seen[k], k .. ' is marked never_sent but not present in docs')
  end
  writeifchanged(filename, pprintYaml(out))
  return out
end

local function rewriteStructures(outApis, outEvents)
  local filename = ('data/products/%s/structures.yaml'):format(product)
  local structures = require('wowapi.yaml').parseFile(filename)
  for name, tab in pairs(tabs) do
    if tab.Type == 'Structure' then
      local ns = split(name)
      structures[name] = (function()
        local ret = {}
        for _, f in ipairs(tab.Fields) do
          ret[f.Name] = {
            default = enum[f.Type] and enum[f.Type][f.Default] or f.Default,
            nilable = f.Nilable or nil,
            stub = deref(structures, name, 'fields', f.Name, 'stub'),
            type = t2nty(f, ns),
          }
        end
        return { fields = ret }
      end)()
    end
  end
  local out = {}
  -- Only write transitive closure of referenced structures.
  local function processType(ty)
    if ty.structure and not out[ty.structure] then
      out[ty.structure] = structures[ty.structure]
      for _, v in pairs(structures[ty.structure].fields) do
        processType(v.type)
      end
    elseif ty.arrayof then
      processType(ty.arrayof)
    end
  end
  local function processList(xs)
    for _, x in ipairs(xs or {}) do
      processType(x.type)
    end
  end
  for _, api in pairs(outApis) do
    processList(api.inputs)
    processList(api.outputs)
  end
  for _, event in pairs(outEvents) do
    processList(event.payload)
  end
  writeifchanged(filename, pprintYaml(out))
end

local outApis = rewriteApis()
local outEvents = rewriteEvents()
rewriteStructures(outApis, outEvents)

local unused_typedefs = {}
for k in pairs(typedefs) do
  if not used_typedefs[k] then
    unused_typedefs[k] = true
  end
end
assert(not next(unused_typedefs), 'unused typedefs = ' .. require('pl.pretty').write(unused_typedefs))
