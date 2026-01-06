local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to process')
  return parser:parse()
end)()

local lfs = require('lfs')
local writeifchanged = require('tools.util').writeifchanged
local tedit = require('tools.tedit')
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

local function take(t, k, ...)
  local tk = t[k]
  if tk == nil then
    return nil
  elseif select('#', ...) == 0 then
    t[k] = nil
    return tk
  else
    local v = take(tk, ...)
    if not next(tk) then
      t[k] = nil
    end
    return v
  end
end

local function takelieor(v, lies, ...)
  local lie = take(lies, ...)
  if not lie then
    return v
  end
  local success, val = pcall(tedit, v, lie)
  if not success then
    error(('tedit failure on %s: %s'):format(table.concat({ ... }, '.'), val))
  end
  return val
end

local function assertTaken(s, t)
  if next(t) then
    error(('not all %s were consumed:\n%s'):format(s, pprintYaml(t)), 0)
  end
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
          local fn, success, err
          fn, err = loadfile(docdir .. '/' .. f)
          if fn then
            success, err = pcall(setfenv(fn, {
              APIDocumentation = {
                AddDocumentationTable = function(_, t)
                  assert(xpcall(require('wowapi.schema').validate, pprintYaml, product, schema, t))
                  docs[f] = t
                end,
              },
              Constants = setmetatable({}, nsmt),
              CreateFromMixins = function()
                return setmetatable({}, mixmt)
              end,
              Enum = setmetatable({}, nsmt),
            }))
          end
          if not success then
            print(('error loading %s: %s'):format(f, err))
          end
        end
      end
    end
  end
  local prefix = 'build/cmake/extracts/' .. product .. '/Interface/AddOns/'
  processDocDir(prefix .. 'Blizzard_APIDocumentation')
  processDocDir(prefix .. 'Blizzard_APIDocumentationGenerated')
end

local config = parseYaml('data/products/' .. product .. '/docs.yaml')
local enum = parseYaml('data/products/' .. product .. '/globals.yaml').Enum

local extra_events = deref(config, 'lies', 'extra_events') or {}
local extra_script_objects = deref(config, 'lies', 'extra_script_objects') or {}
local tabs, funcs, events, scrobjs = {}, {}, {}, {}
for _, t in pairs(docs) do
  for _, tab in ipairs(t.Tables or {}) do
    local name = (t.Namespace and (t.Namespace .. '.') or '') .. tab.Name
    assert(not tabs[name])
    tabs[name] = tab
  end
  if not t.Type or t.Type == 'System' then
    for _, func in ipairs(t.Functions or {}) do
      local ns = func.Namespace or t.Namespace
      local name = (ns and ns ~= '' and (ns .. '.') or '') .. func.Name
      assert(not funcs[name])
      funcs[name] = func
      func.Environment = t.Environment
    end
    for _, event in ipairs(t.Events or {}) do
      local name = (t.Namespace and (t.Namespace .. '.') or '') .. event.Name
      assert(not events[name])
      events[name] = not take(extra_events, event.LiteralName) and event or nil
    end
  elseif t.Type == 'ScriptObject' and not take(extra_script_objects, t.Name) then
    assert(config.script_objects[t.Name], 'missing script object mapping for ' .. t.Name)
    assert(not scrobjs[t.Name])
    assert(not next(t.Events))
    scrobjs[t.Name] = t
  end
end
assertTaken('lies.extra_events', extra_events)
assertTaken('lies.extra_script_objects', extra_script_objects)

for k in pairs(config.script_objects) do
  assert(scrobjs[k], 'redundant script object mapping ' .. k)
end

local typedefs = config.typedefs or {}
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
for k in pairs(parseYaml('data/stringenums.yaml')) do
  tys[k] = tys[k] or 'stringenum'
end
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
    return typedefs[t].type, typedefs[t].outnil
  end
  local n = ns and tys[ns .. '.' .. t] and (ns .. '.' .. t) or t
  local ty = tys[n]
  assert(ty, 'wtf ' .. n)
  if ty == 'Constants' then
    return 'number'
  elseif ty == 'Enumeration' then
    return { enum = t }
  elseif ty == 'stringenum' then
    return { stringenum = t }
  elseif ty == 'Structure' then
    if field.Mixin and field.Mixin ~= structs[n].mixin then
      error(('expected struct %s to have mixin %s'):format(n, field.Mixin))
    end
    return { structure = n }
  elseif ty == 'CallbackType' then
    return 'function'
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

local function default(x)
  if x.Type == 'luaIndex' and x.Default then
    return x.Default + 1
  end
  return enum[x.Type] and enum[x.Type][x.Default] or x.Default
end

local function insig(fn, ns, api)
  local permissives = {}
  for _, input in ipairs(api and api.inputs or {}) do
    if input.name then
      permissives[input.name] = input.permissive
    end
  end
  local t = {}
  for _, a in ipairs(fn.Arguments or {}) do
    if a.Type == 'UnitToken' and a.Default == 'WOWGUID_NULL' then
      table.insert(t, {
        name = a.Name,
        nilable = true,
        type = 'unit',
      })
    elseif a.Type == 'uiRect' then
      assert(a.Default == nil)
      assert(not a.Nilable)
      assert(not a.StrideIndex)
      for _, p in ipairs({ 'Left', 'Right', 'Top', 'Bottom' }) do
        table.insert(t, {
          name = a.Name .. p,
          type = 'number',
        })
      end
    else
      local def = default(a)
      table.insert(t, {
        default = def,
        name = a.Name,
        nilable = a.Nilable and def == nil or nil,
        permissive = take(permissives, a.Name),
        type = t2nty(a, ns),
      })
    end
  end
  local fname = (ns and (ns .. '.') or '') .. fn.Name
  assertTaken(fname .. ' permissives', permissives)
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
    if r.Type == 'uiRect' then
      assert(r.Default == nil)
      assert(not r.Nilable)
      assert(not r.StrideIndex)
      for _, p in ipairs({ 'Left', 'Right', 'Top', 'Bottom' }) do
        table.insert(outputs, {
          name = r.Name .. p,
          type = 'number',
        })
      end
    else
      local ty, outnil = t2nty(r, ns)
      table.insert(outputs, {
        default = default(r),
        name = r.Name,
        nilable = r.Nilable and ty ~= 'nil' or outnil,
        stub = take(stubs, r.Name),
        stubnotnil = take(stubnotnils, r.Name),
        type = ty,
      })
    end
  end
  local fname = (ns and (ns .. '.') or '') .. fn.Name
  assertTaken(fname .. ' stubs', stubs)
  assertTaken(fname .. ' stubnotnils', stubnotnils)
  return outputs
end

local function rewriteApis(apis)
  local lies = deref(config, 'lies', 'apis') or {}
  local extras = deref(config, 'lies', 'extra_apis') or {}
  for name, fn in pairs(funcs) do
    local ns = split(name)
    local api = apis[name]
    local newapi = {
      impl = api and api.impl,
      inputs = insig(fn, ns, api),
      instride = stride(fn.Arguments),
      mayreturnnothing = fn.MayReturnNothing,
      outputs = outsig(fn, ns, api),
      outstride = stride(fn.Returns),
      platform = api and api.platform,
      secureonly = fn.Environment == 'SecureOnly' or nil,
      stubnothing = api and api.stubnothing,
      stuboutstrides = api and api.stuboutstrides,
    }
    if not take(extras, name) then
      apis[name] = takelieor(newapi, lies, name)
    end
  end
  assertTaken('lies', lies)
  assertTaken('extras', extras)
end

local function rewriteEvents(out)
  for name, ev in pairs(events) do
    local ns = split(name)
    local payload = {}
    for _, arg in ipairs(ev.Payload or {}) do
      table.insert(payload, {
        default = default(arg),
        name = arg.Name,
        nilable = arg.Nilable or nil,
        type = t2nty(arg, ns),
      })
    end
    out[ev.LiteralName] = {
      callback = ev.CallbackEvent,
      payload = payload,
      stride = stride(ev.Payload),
    }
  end
end

local function rewriteGlobals(out)
  local lies = deref(config, 'lies', 'enums') or {}
  local extras = deref(config, 'lies', 'extra_enums') or {}
  for _, tab in pairs(tabs) do
    if tab.Type == 'Enumeration' and not take(extras, tab.Name) then
      local t = {}
      for _, v in ipairs(tab.Fields) do
        assert(v.Type == tab.Name, v.Name)
        t[v.Name] = v.EnumValue
      end
      out.Enum[tab.Name] = takelieor(t, lies, tab.Name)
      out.Enum[tab.Name .. 'Meta'] = {
        MaxValue = tab.MaxValue < 2 ^ 31 and tab.MaxValue or tab.MaxValue - 2 ^ 32,
        MinValue = tab.MinValue,
        NumValues = tab.NumValues,
      }
    end
  end
  assertTaken('lies.enums', lies)
  assertTaken('lies.extra_enums', extras)
end

local function rewriteStructures(structures, outApis, outEvents, outUIObjects)
  for name, tab in pairs(tabs) do
    if tab.Type == 'Structure' then
      local ns = split(name)
      structures[name] = (function()
        local ret = {}
        for _, f in ipairs(tab.Fields) do
          ret[f.Name] = {
            default = default(f),
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
  for _, uiobject in pairs(outUIObjects) do
    for _, field in pairs(uiobject.fields) do
      processType(field.type)
    end
    for _, method in pairs(uiobject.methods) do
      processList(method.inputs)
      processList(method.outputs)
    end
  end
  for k in pairs(structures) do
    structures[k] = nil
  end
  for k, v in pairs(out) do
    structures[k] = v
  end
end

local function rewriteUIObjects(uiobjects)
  local ignores = config.ignore_script_object_methods or {}
  local pscrobjs = {}
  for _, t in pairs(scrobjs) do
    local fns = {}
    for _, fn in ipairs(t.Functions) do
      assert(not fns[fn.Name])
      fns[fn.Name] = not take(ignores, t.Name, fn.Name) and fn or nil
    end
    pscrobjs[t.Name] = fns
  end
  assertTaken('ignore_script_object_methods', ignores)
  local mapped = {}
  for k, v in pairs(pscrobjs) do
    local mmk = assert(config.script_objects[k], 'unknown doc type ' .. k)
    local t = mapped[mmk] or {}
    for mk, mv in pairs(v) do
      assert(not t[mk], 'multiple specs for ' .. k .. '.' .. mk)
      t[mk] = mv
    end
    mapped[mmk] = t
  end
  local lies = deref(config, 'lies', 'uiobjects') or {}
  local reassigns = config.uiobject_method_reassignments or {}
  local inhm = {}
  local function inhprocess(k)
    if inhm[k] then
      return
    end
    local t = {}
    local v = assert(uiobjects[k])
    for vk in pairs(v.inherits) do
      inhprocess(vk)
      for tk in pairs(inhm[vk]) do
        t[tk] = true
      end
      for mk in pairs(uiobjects[vk].methods) do
        t[mk] = true
      end
    end
    inhm[k] = t
  end
  for k in pairs(uiobjects) do
    inhprocess(k)
  end
  for k, v in pairs(mapped) do
    for mk, mv in pairs(v) do
      local kk = take(reassigns, k, mk) or k
      local u = assert(uiobjects[kk], 'unknown uiobject type ' .. kk)
      local mm = u.methods[mk]
      local mmv = {
        impl = mm and mm.impl,
        inputs = insig(mv, nil, mm),
        instride = stride(mv.Arguments),
        manualinputs = mm and mm.manualinputs,
        mayreturnnothing = mv.MayReturnNothing,
        override = mm and mm.override,
        outputs = outsig(mv, nil, mm),
        outstride = stride(mv.Returns),
        stuboutstrides = mm and mm.stuboutstrides,
      }
      if not inhm[kk][mk] or mmv.override then
        u.methods[mk] = takelieor(mmv, lies, kk, mk)
      end
    end
  end
  assertTaken('lies', lies)
  assertTaken('reassigns', reassigns)
end

local rewriteFuncs = {
  apis = rewriteApis,
  events = rewriteEvents,
  globals = rewriteGlobals,
  structures = rewriteStructures,
  uiobjects = rewriteUIObjects,
}
local rewriteDeps = {
  structures = { 'apis', 'events', 'uiobjects' },
}
local tt = require('resty.tsort').new()
for k in pairs(rewriteFuncs) do
  tt:add(k)
end
for k, v in pairs(rewriteDeps) do
  for _, vv in ipairs(v) do
    tt:add(vv, k)
  end
end

local datas = {}
for _, r in ipairs(assert(tt:sort())) do
  local data = parseYaml(('data/products/%s/%s.yaml'):format(product, r))
  local rargs = {}
  for _, vv in ipairs(rewriteDeps[r] or {}) do
    table.insert(rargs, datas[vv])
  end
  rewriteFuncs[r](data, unpack(rargs))
  datas[r] = data
end

local unused_typedefs = {}
for k in pairs(typedefs) do
  if not used_typedefs[k] then
    unused_typedefs[k] = true
  end
end
assert(not next(unused_typedefs), 'unused typedefs:\n' .. pprintYaml(unused_typedefs))

for k, v in pairs(datas) do
  writeifchanged(('data/products/%s/%s.yaml'):format(product, k), pprintYaml(v))
end
