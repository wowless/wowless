local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:option('--sqls', 'sqls file')
  parser:option('-o --output', 'output file')
  parser:option('--coutput', 'C stubs output file'):count('1')
  return parser:parse()
end)()

local deps = {} -- accumulated during runtime

local function parseYaml(f)
  deps[f] = true
  return (assert(require('wowapi.yaml').parseFile(f)))
end
local function readFile(f)
  deps[f] = true
  return (assert(require('pl.file').read(f)))
end
local prettywrite = require('tools.prettywrite')
local Mixin = require('wowless.util').mixin
local sorted = require('pl.tablex').sort

local product = args.product
local globals = parseYaml('data/products/' .. product .. '/globals.yaml')
local structures = parseYaml('data/products/' .. product .. '/structures.yaml')
local stringenums = parseYaml('data/stringenums.yaml')

local function valstr(value)
  local ty = type(value)
  if ty == 'number' or ty == 'boolean' then
    return tostring(value)
  elseif ty == 'string' then
    return string.format('%q', value)
  elseif ty == 'table' then
    return prettywrite(value, true)
  else
    error('unsupported stub value type ' .. ty)
  end
end

local function dispatch(t, u, ...)
  if type(u) == 'string' then
    return assert(t[u], u)(...)
  else
    local uk, uv = next(u)
    assert(next(u, uk) == nil, uk)
    return assert(t[uk], uk)(uv, ...)
  end
end

local sqlcfg = parseYaml(args.sqls)
local sqls = {}
local function ensuresql(k)
  if not sqls[k] then
    local sql = assert(sqlcfg[k], k)
    sqls[k] = {
      sql = sql.text,
      table = sql.config.table,
      type = sql.config.type,
    }
  end
end

local implimpls = {
  delegate = function(impl)
    return {
      impl = 'return debug.newcfunction(' .. impl .. ')',
      nowrap = true,
    }
  end,
  directsql = function(impl)
    ensuresql(impl)
    return {
      impl = 'return (...)',
      sqls = { impl },
    }
  end,
  impl = function(impl, name)
    local modules
    if impl.modules then
      modules = {}
      for m in sorted(impl.modules) do
        table.insert(modules, m)
      end
    end
    for _, sql in ipairs(impl.sqls or {}) do
      ensuresql(sql)
    end
    local src = 'data/impl/' .. name .. '.lua'
    return {
      impl = readFile(src),
      modules = modules,
      sqls = impl.sqls,
      src = '@./' .. src,
    }
  end,
  luadelegate = function(impl, name)
    local fmt = 'return require(%q)[%q]'
    return {
      impl = fmt:format(impl.module, impl['function'] or name),
      nowrap = impl.nowrap,
    }
  end,
  moduledelegate = function(impl, name)
    return {
      impl = ('return (...)[%q]'):format(impl['function'] or name),
      modules = { impl.name },
      nobubblewrap = impl.nobubblewrap,
      nowrap = impl.nowrap,
    }
  end,
  stdlib = function(path)
    return {
      impl = 'return ' .. path,
      nowrap = true,
    }
  end,
}
local implcfg = parseYaml('data/impl.yaml')
local impls = {}
local function ensureimpl(k)
  if not impls[k] then
    local cfg = assert(implcfg[k], k)
    impls[k] = dispatch(implimpls, cfg, k)
  end
  return impls[k]
end

local cvars = {}
for k, v in pairs(parseYaml('data/products/' .. product .. '/cvars.yaml')) do
  local lk = k:lower()
  assert(not cvars[lk], lk)
  cvars[lk] = {
    name = k,
    value = v,
  }
end

local eventcfg = parseYaml('data/products/' .. product .. '/events.yaml')
local events = {}
for k, v in pairs(eventcfg) do
  events[k] = {
    callback = v.callback,
    noscript = v.noscript,
    nullary = not next(v.payload) or nil,
    restricted = v.restricted,
  }
end

local uiobjectdata = parseYaml('data/products/' .. product .. '/uiobjects.yaml')
local uitype_bits = {}
do
  local i = 0
  for name in sorted(uiobjectdata) do
    uitype_bits[name] = i
    i = i + 1
  end
end
local uitype_ancestors = {}
local function computeAncestors(k)
  if uitype_ancestors[k] then
    return uitype_ancestors[k]
  end
  local ancestors = {}
  local bit = uitype_bits[k]
  if bit then
    ancestors[bit] = true
  end
  for inh in pairs(uiobjectdata[k].inherits) do
    for b in pairs(computeAncestors(inh)) do
      ancestors[b] = true
    end
  end
  uitype_ancestors[k] = ancestors
  return ancestors
end
for k in pairs(uiobjectdata) do
  computeAncestors(k)
end
local uiobjectimpl = parseYaml('data/uiobjectimpl.yaml')
local uiobjectinits = {}
local function mkuiobjectinit(k)
  local init = uiobjectinits[k]
  if not init then
    init = {}
    local v = uiobjectdata[k]
    for inh in pairs(v.inherits) do
      Mixin(init, mkuiobjectinit(inh))
    end
    for fk, fv in pairs(v.fieldinitoverrides or {}) do
      init[fk] = valstr(fv)
    end
    for fk, fv in pairs(v.fields) do
      if fv.init ~= nil then
        init[fk] = valstr(fv.init)
      elseif fv.type == 'hlist' then
        init[fk] = 'gencode.hlist()'
      end
    end
    if k == 'EditBox' or k == 'MessageFrame' then -- TODO unhack
      init.fontObject = 'gencode.CreateUIObject(\'font\')'
    end
    uiobjectinits[k] = init
  end
  return init
end
local uiobjectimplimplmakers = {
  luafile = function(impl, k)
    local modules
    if impl.modules then
      modules = {}
      for m in sorted(impl.modules) do
        table.insert(modules, m)
      end
    end
    for _, sql in ipairs(impl.sqls or {}) do
      ensuresql(sql)
    end
    local src = 'data/uiobjects/' .. k .. '.lua'
    return {
      cstub = true,
      impl = readFile(src),
      modules = modules,
      sqls = impl.sqls,
      src = '@./' .. src,
    }
  end,
  moduledelegate = function(impl, k)
    return {
      cstub = true,
      impl = ('return (...)[%q]'):format(k:sub(k:find('/') + 1)),
      modules = { impl.name },
    }
  end,
}
local uiobjectimplmakers = {
  none = function()
    return {
      cstub = true,
      impl = 'return function() end',
      modules = {},
    }
  end,
  getter = function(impl)
    local t = { 'return function(self)return ' }
    for i, f in ipairs(impl) do
      table.insert(t, (i == 1 and '' or ',') .. 'self.' .. f.name)
    end
    table.insert(t, ' end')
    return {
      cstub = true,
      impl = table.concat(t),
      modules = {},
    }
  end,
  setter = function(impl, mv)
    local t = { 'return function(self' }
    for _, f in ipairs(impl) do
      table.insert(t, ',')
      table.insert(t, f.name)
    end
    table.insert(t, ')')
    for i, f in ipairs(impl) do
      local spec = mv.inputs[i]
      table.insert(t, 'self.')
      table.insert(t, f.name)
      table.insert(t, '=')
      if spec and spec.default ~= nil then
        table.insert(t, f.name .. '~=nil and ' .. f.name .. ' or ' .. valstr(spec.default))
      else
        table.insert(t, f.name)
      end
      table.insert(t, ';')
    end
    table.insert(t, 'end')
    return {
      cstub = true,
      impl = table.concat(t),
      modules = {},
    }
  end,
  settexture = function(impl)
    local t = { 'local gencode=...;return function(self,tex)' }
    table.insert(t, 'local t=gencode.ToTexture(self,tex,self.')
    table.insert(t, impl.field)
    table.insert(t, ');if t then gencode.SetParent(t,self);if t:GetNumPoints()==0 then t:SetAllPoints()end t:SetShown(')
    table.insert(t, impl.shown or 'true')
    table.insert(t, ');')
    if impl.extra then
      table.insert(t, impl.extra)
      table.insert(t, ';')
    end
    table.insert(t, 'end self.')
    table.insert(t, impl.field)
    table.insert(t, '=t;')
    if impl['return'] then
      table.insert(t, 'return true;')
    end
    table.insert(t, 'end')
    return {
      cstub = true,
      impl = table.concat(t),
      modules = { 'gencode' },
    }
  end,
  uiobjectimpl = function(impl)
    return dispatch(uiobjectimplimplmakers, uiobjectimpl[impl], impl)
  end,
}
local eligible_uimethods = {}
local uiobjects = {}
for k, v in pairs(uiobjectdata) do
  local constructor = { 'local gencode=...;return function()return{' }
  for fk, fv in sorted(mkuiobjectinit(k)) do
    table.insert(constructor, ('%s=%s,'):format(fk, fv))
  end
  table.insert(constructor, '}end')
  local methods = {}
  for mk, mv in pairs(v.methods) do
    local d = dispatch(uiobjectimplmakers, mv.impl or 'none', mv, k)
    if d.cstub then
      methods[mk] = { cstub = true }
      eligible_uimethods[k .. ':' .. mk] = {
        k = k,
        mk = mk,
        mv = mv,
        implimpl = type(mv.impl) == 'table' and (mv.impl.uiobjectimpl or mv.impl.settexture) and d or nil,
      }
    else
      methods[mk] = Mixin({}, d, {
        inputs = mv.inputs,
        instride = mv.instride,
        mayreturnnothing = mv.mayreturnnothing,
        outputs = mv.outputs,
        outstride = mv.outstride,
      })
    end
  end
  local scripts = {}
  for sk in pairs(v.scripts or {}) do
    scripts[sk:lower()] = true
  end
  uiobjects[k] = {
    constructor = table.concat(constructor),
    inherits = v.inherits,
    methods = methods,
    objectType = v.objectType,
    scripts = scripts,
    singleton = v.singleton,
    uitype_bit = uitype_bits[k],
  }
end

local luaobjects = {}
local luaobjectdata = parseYaml('data/products/' .. product .. '/luaobjects.yaml')
do
  for k, v in pairs(luaobjectdata) do
    luaobjects[k] = {
      impl = v.impl,
      inherits = v.inherits,
      virtual = v.virtual,
    }
  end
end

local xmlraw = parseYaml('data/products/' .. product .. '/xml.yaml')
local xmlimpls = (function()
  local tree = xmlraw
  local newtree = {}
  for k, v in pairs(tree) do
    local attrs = Mixin({}, v.attributes or {})
    local t = v
    while t.extends do
      t = tree[t.extends]
      Mixin(attrs, t.attributes or {})
    end
    local aimpls = {}
    for n, a in pairs(attrs) do
      if a.impl then
        aimpls[n] = {
          impl = a.impl,
          name = n,
          phase = a.phase or 'middle',
        }
      end
    end
    local tag = v.impl
    if type(tag) == 'table' and tag.call and tag.call.argument == 'self' then
      local arg = v.extends
      while tree[arg].virtual do
        arg = tree[arg].extends
      end
      tag = Mixin({}, tag, { call = Mixin({}, tag.call, { argument = arg:lower() }) })
    end
    newtree[k:lower()] = {
      attrs = aimpls,
      phase = v.phase or 'middle',
      tag = tag,
    }
  end
  return newtree
end)()

local xmlflat = (function()
  local tree = xmlraw
  local newtree = {}
  for k, v in pairs(tree) do
    local attrs = {}
    for ak, av in pairs(v.attributes or {}) do
      attrs[ak] = av.type.stringenum or av.type
    end
    local kids = {}
    local text = false
    if v.contents == 'text' then
      text = true
    elseif v.contents then
      for kid in pairs(v.contents.tags) do
        local key = kid:lower()
        assert(not kids[key], kid .. ' is already a child of ' .. k)
        kids[key] = true
      end
    end
    local supertypes = { [k:lower()] = true }
    local t = v
    while t.extends do
      supertypes[t.extends:lower()] = true
      t = tree[t.extends]
      for ak, av in pairs(t.attributes or {}) do
        assert(not attrs[ak], ak .. ' is already an attribute of ' .. k)
        attrs[ak] = av.type.stringenum or av.type
      end
      if t.contents == 'text' then
        text = true
      elseif t.contents then
        for kid in pairs(t.contents.tags) do
          local key = kid:lower()
          assert(not kids[key], kid .. ' is already a child of ' .. k)
          kids[key] = true
        end
      end
    end
    assert(not text or #kids == 0, 'both text and kids on ' .. k)
    newtree[k:lower()] = {
      attributes = attrs,
      children = kids,
      supertypes = supertypes,
      text = text,
    }
  end
  return newtree
end)()

local data = {
  build = parseYaml('data/products/' .. product .. '/build.yaml'),
  config = parseYaml('data/products/' .. product .. '/config.yaml'),
  cvars = cvars,
  events = events,
  globals = globals,
  luaobjects = luaobjects,
  product = product,
  sqls = sqls,
  structures = structures,
  uiobjects = uiobjects,
  xmlflat = xmlflat,
  xmlimpls = xmlimpls,
}

local function safename(s)
  return s:gsub('[%.:]', '_')
end

local function cstring(s)
  return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n'):gsub('\r', '\\r'):gsub('\t', '\\t') .. '"'
end

local coutdefaults
coutdefaults = {
  arrayof = function(inner)
    return { dispatch(coutdefaults, inner) }
  end,
  boolean = function()
    return false
  end,
  FileAsset = function()
    return 1
  end,
  enum = function(enumname)
    local meta = assert(globals.Enum[enumname .. 'Meta'], 'missing meta enum for ' .. enumname)
    return (assert(meta.MinValue, 'missing MinValue in meta for ' .. enumname))
  end,
  ['nil'] = function()
    return nil
  end,
  number = function()
    return 1
  end,
  oneornil = function()
    return nil
  end,
  string = function()
    return ''
  end,
  stringenum = function(name)
    local least
    for k in pairs(stringenums[name]) do
      least = (least == nil or k < least) and k or least
    end
    return least
  end,
  structure = function(name)
    local st = assert(structures[name], name)
    local result = {}
    for fname, field in pairs(st.fields) do
      local fval
      if field.stub ~= nil then
        fval = field.stub
      elseif field.default ~= nil then
        fval = field.default
      elseif not field.nilable or field.stubnotnil then
        fval = dispatch(coutdefaults, field.type)
      end
      if fval ~= nil then
        result[fname] = fval
      end
    end
    return result
  end,
  luaobject = function(name)
    return name
  end,
  table = function()
    return {}
  end,
  uiobject = function(name)
    return name
  end,
  unit = function()
    return 'player'
  end,
  unknown = function()
    return nil
  end,
}

local function simple_cinputtype(suffix)
  local fn = function(verb, nilable, idx)
    return string.format('wowless_%s%s%s(L, %s)', verb, nilable and 'nilable' or '', suffix, idx)
  end
  return function()
    return fn
  end
end
local cinputtypes
cinputtypes = {
  any = simple_cinputtype('any'),
  arrayof = function(inner)
    local inner_fn = dispatch(cinputtypes, inner)
    local check_name = inner_fn('stubcheck', false, 0):match('^(.-)%(')
    return function(verb, nilable, idx)
      local effective_verb = verb == 'implcheck' and 'stubcheck' or verb
      return string.format(
        'wowless_%s%sarrayof<%s>(L, %s)',
        effective_verb,
        nilable and 'nilable' or '',
        check_name,
        idx
      )
    end
  end,
  boolean = simple_cinputtype('boolean'),
  enum = simple_cinputtype('enum'),
  FileAsset = simple_cinputtype('fileasset'),
  TextureAsset = simple_cinputtype('textureasset'),
  ['function'] = simple_cinputtype('function'),
  gender = simple_cinputtype('gender'),
  ['nil'] = simple_cinputtype('nil'),
  luaobject = function(name)
    return function(verb, nilable, idx)
      local ns = nilable and 'nilable' or ''
      return string.format('wowless_%s%sluaobject_%s(L, %s)', verb, ns, safename(name), idx)
    end
  end,
  number = simple_cinputtype('number'),
  string = simple_cinputtype('string'),
  stringenum = function(name)
    local n = 0
    for _ in pairs(stringenums[name]) do
      n = n + 1
    end
    return function(verb, nilable, idx)
      return string.format(
        'wowless_%s%sstringenum(L, %s, wowless_stringenum_%s_values, %d)',
        verb,
        nilable and 'nilable' or '',
        idx,
        safename(name),
        n
      )
    end
  end,
  structure = function(name)
    assert(structures[name], name)
    return function(_, nilable, idx)
      return string.format('wowless_stubcheck%sstruct_%s(L, %s)', nilable and 'nilable' or '', safename(name), idx)
    end
  end,
  table = simple_cinputtype('table'),
  uiAddon = simple_cinputtype('uiaddon'),
  uiobject = function(name)
    return function(verb, nilable, idx)
      return string.format('wowless_%s%suiobject_%s(L, %s)', verb, nilable and 'nilable' or '', safename(name), idx)
    end
  end,
  unit = simple_cinputtype('unit'),
  unknown = simple_cinputtype('unknown'),
}

local function simple_coutputtype(suffix)
  return function(nilable, idx)
    return string.format('wowless_imploutput%s%s(L, %s)', nilable and 'nilable' or '', suffix, idx)
  end
end

local coutputtypes
coutputtypes = {
  any = simple_coutputtype('any'),
  arrayof = function(inner, nilable, idx)
    local inner_fn = dispatch(cinputtypes, inner)
    local check_name = inner_fn('stubcheck', false, 0):match('^(.-)%(')
    return string.format('wowless_stubcheck%sarrayof<%s>(L, %s)', nilable and 'nilable' or '', check_name, idx)
  end,
  boolean = simple_coutputtype('boolean'),
  enum = function(_, nilable, idx)
    return (simple_coutputtype('enum'))(nilable, idx)
  end,
  FileAsset = simple_coutputtype('fileasset'),
  ['function'] = simple_coutputtype('function'),
  luaobject = function(typename, nilable, idx)
    local ns = nilable and 'nilable' or ''
    return string.format('wowless_imploutput%sluaobject_%s(L, %s)', ns, safename(typename), idx)
  end,
  ['nil'] = simple_coutputtype('nil'),
  number = simple_coutputtype('number'),
  oneornil = simple_coutputtype('oneornil'),
  string = simple_coutputtype('string'),
  stringenum = function(name, nilable, idx)
    local n = 0
    for _ in pairs(stringenums[name]) do
      n = n + 1
    end
    local ns = nilable and 'nilable' or ''
    return string.format(
      'wowless_imploutput%sstringenum(L, %s, wowless_stringenum_%s_values, %d)',
      ns,
      idx,
      safename(name),
      n
    )
  end,
  structure = function(name, nilable, idx)
    return string.format('wowless_stubcheck%sstruct_%s(L, %s)', nilable and 'nilable' or '', safename(name), idx)
  end,
  table = simple_coutputtype('table'),
  uiobject = function(typename, nilable, idx)
    local ns = nilable and 'nilable' or ''
    return string.format('wowless_imploutput%suiobject(L, %s, %d)', ns, idx, assert(uitype_bits[typename], typename))
  end,
  unit = simple_coutputtype('unit'),
  unknown = simple_coutputtype('unknown'),
}

local lines = {}
local function emit(fmt, ...)
  table.insert(lines, string.format(fmt, ...))
end

emit('#include "wowless/typecheck.h"')
emit('')

-- Assign integer typeids to all luaobject types (sorted for determinism)
local luaobject_typeids = {}
do
  local i = 0
  for loname in sorted(luaobjectdata) do
    luaobject_typeids[loname] = i
    i = i + 1
  end
end

-- Flatten luaobject methods per type (resolve inheritance), tracking source type.
local luaobject_flat = {} -- [loname][mname] = method_config
local luaobject_source = {} -- [loname][mname] = source_typename
local function lo_flatten(k)
  if luaobject_flat[k] then
    return luaobject_flat[k]
  end
  local v = luaobjectdata[k]
  local flat = {}
  local src = {}
  if v.inherits then
    lo_flatten(v.inherits)
    for mk, me in pairs(luaobject_flat[v.inherits]) do
      flat[mk] = me
      src[mk] = luaobject_source[v.inherits][mk]
    end
  end
  for mk, mv in pairs(v.methods or {}) do
    flat[mk] = mv
    src[mk] = k
  end
  luaobject_flat[k] = flat
  luaobject_source[k] = src
  return flat
end
for loname in pairs(luaobjectdata) do
  lo_flatten(loname)
end

local lua_value_emitters
lua_value_emitters = {
  boolean = function(v)
    emit('  lua_pushboolean(L, %d);', v and 1 or 0)
  end,
  number = function(v)
    emit('  lua_pushnumber(L, %g);', v)
  end,
  string = function(v)
    emit('  lua_pushliteral(L, %s);', cstring(v))
  end,
  table = function(v)
    local n = 0
    for _ in pairs(v) do
      n = n + 1
    end
    emit('  lua_createtable(L, 0, %d);', n)
    for vk, vv in pairs(v) do
      dispatch(lua_value_emitters, type(vk), vk)
      dispatch(lua_value_emitters, type(vv), vv)
      emit('  lua_rawset(L, -3);')
    end
  end,
}

local coutpushers
coutpushers = {
  arrayof = function(inner, val)
    emit('  lua_createtable(L, %d, 0);', #val)
    for i, elem in ipairs(val) do
      dispatch(coutpushers, inner, elem)
      emit('  lua_rawseti(L, -2, %d);', i)
    end
  end,
  boolean = lua_value_emitters.boolean,
  enum = function(_, val)
    lua_value_emitters.number(val)
  end,
  FileAsset = lua_value_emitters.number,
  number = lua_value_emitters.number,
  string = lua_value_emitters.string,
  stringenum = lua_value_emitters.string,
  structure = function(name, val)
    local st = assert(structures[name], name)
    local n = 0
    for _ in pairs(val) do
      n = n + 1
    end
    emit('  lua_createtable(L, 0, %d);', n)
    for fname, fval in pairs(val) do
      lua_value_emitters.string(fname)
      dispatch(coutpushers, st.fields[fname].type, fval)
      emit('  lua_rawset(L, -3);')
    end
    if st.mixin then
      emit('  wowless_applymixin(L, %s);', cstring(st.mixin))
    end
  end,
  luaobject = function(name, _)
    emit('  wowless_stubcreateluaobject(L, %s);', cstring(name))
  end,
  table = lua_value_emitters.table,
  uiobject = function(name, _)
    emit('  wowless_stubcreateuiobject(L, %s);', cstring(name))
  end,
}

for sname in sorted(structures) do
  emit('static void wowless_stubcheckstruct_%s(lua_State *L, int idx);', safename(sname))
  emit('static void wowless_stubchecknilablestruct_%s(lua_State *L, int idx);', safename(sname))
end
if next(structures) then
  emit('')
end
for sename, sevalues in sorted(stringenums) do
  local values = {}
  for k in pairs(sevalues) do
    values[#values + 1] = k
  end
  table.sort(values)
  local entries = {}
  for _, v in ipairs(values) do
    entries[#entries + 1] = cstring(v)
  end
  emit(
    'static const char * const wowless_stringenum_%s_values[] = {%s};',
    safename(sename),
    table.concat(entries, ', ')
  )
end
if next(stringenums) then
  emit('')
end
for uname in sorted(uiobjectdata) do
  emit('static bool wowless_isuiobject_%s(lua_State *L, int idx);', safename(uname))
  emit('static bool wowless_isnilableuiobject_%s(lua_State *L, int idx);', safename(uname))
  emit('static void wowless_stubcheckuiobject_%s(lua_State *L, int idx);', safename(uname))
  emit('static void wowless_stubchecknilableuiobject_%s(lua_State *L, int idx);', safename(uname))
  emit('static void wowless_implcheckuiobject_%s(lua_State *L, int idx);', safename(uname))
  emit('static void wowless_implchecknilableuiobject_%s(lua_State *L, int idx);', safename(uname))
end
emit('')
for loname in sorted(luaobjectdata) do
  emit('static bool wowless_isluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static bool wowless_isnilableluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static void wowless_stubcheckluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static void wowless_stubchecknilableluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static void wowless_implcheckluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static void wowless_implchecknilableluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static void wowless_imploutputluaobject_%s(lua_State *L, int idx);', safename(loname))
  emit('static void wowless_imploutputnilableluaobject_%s(lua_State *L, int idx);', safename(loname))
end
emit('')

for sname, st in sorted(structures) do
  emit('static void wowless_stubcheckstruct_%s(lua_State *L, int idx) {', safename(sname))
  emit('  idx = lua_absindex(L, idx);')
  emit('  wowless_stubchecktable(L, idx);')
  for fname, field in sorted(st.fields) do
    local field_nilable = field.nilable or field.default ~= nil
    local ftype = field.type
    emit('  lua_pushliteral(L, %s);', cstring(fname))
    emit('  lua_rawget(L, idx);')
    emit('  %s;', dispatch(cinputtypes, ftype)('stubcheck', field_nilable, -1))
    emit('  lua_pop(L, 1);')
  end
  emit('}')
  emit('')
  emit('static void wowless_stubchecknilablestruct_%s(lua_State *L, int idx) {', safename(sname))
  emit('  if (!lua_isnoneornil(L, idx)) {')
  emit('    wowless_stubcheckstruct_%s(L, idx);', safename(sname))
  emit('  }')
  emit('}')
  emit('')
end

for uname in sorted(uiobjectdata) do
  emit('static bool wowless_isuiobject_%s(lua_State *L, int idx) {', safename(uname))
  emit('  return wowless_isuiobject(L, idx, %d);', uitype_bits[uname])
  emit('}')
  emit('')
  emit('static bool wowless_isnilableuiobject_%s(lua_State *L, int idx) {', safename(uname))
  emit('  return wowless_isnilableuiobject(L, idx, %d);', uitype_bits[uname])
  emit('}')
  emit('')
  emit('static void wowless_stubcheckuiobject_%s(lua_State *L, int idx) {', safename(uname))
  emit('  if (!wowless_isuiobject_%s(L, idx)) luaL_typerror(L, idx, "uiobject");', safename(uname))
  emit('}')
  emit('')
  emit('static void wowless_stubchecknilableuiobject_%s(lua_State *L, int idx) {', safename(uname))
  emit('  if (!wowless_isnilableuiobject_%s(L, idx)) luaL_typerror(L, idx, "uiobject");', safename(uname))
  emit('}')
  emit('')
  emit('static void wowless_implcheckuiobject_%s(lua_State *L, int idx) {', safename(uname))
  if uname == 'Font' then
    emit('  if (lua_type(L, idx) == LUA_TSTRING) {')
    emit('    lua_getglobal(L, lua_tostring(L, idx));')
    emit('    lua_replace(L, idx);')
    emit('  }')
  end
  emit('  wowless_implcheckuiobject(L, idx, %d);', uitype_bits[uname])
  emit('}')
  emit('')
  emit('static void wowless_implchecknilableuiobject_%s(lua_State *L, int idx) {', safename(uname))
  if uname == 'Font' then
    emit('  if (!lua_isnoneornil(L, idx)) {')
    emit('    wowless_implcheckuiobject_%s(L, idx);', safename(uname))
    emit('  }')
  else
    emit('  wowless_implchecknilableuiobject(L, idx, %d);', uitype_bits[uname])
  end
  emit('}')
  emit('')
end

for loname in sorted(luaobjectdata) do
  local tid = luaobject_typeids[loname]
  emit('static bool wowless_isluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  return wowless_isluaobject(L, idx, %d);', tid)
  emit('}')
  emit('')
  emit('static bool wowless_isnilableluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  return wowless_isnilableluaobject(L, idx, %d);', tid)
  emit('}')
  emit('')
  emit('static void wowless_stubcheckluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  wowless_stubcheckluaobject(L, idx, %d);', tid)
  emit('}')
  emit('')
  emit('static void wowless_stubchecknilableluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  wowless_stubchecknilableluaobject(L, idx, %d);', tid)
  emit('}')
  emit('')
  emit('static void wowless_implcheckluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  wowless_implcheckluaobject(L, idx, %d, %s);', tid, cstring(loname))
  emit('}')
  emit('')
  emit('static void wowless_implchecknilableluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  wowless_implchecknilableluaobject(L, idx, %d, %s);', tid, cstring(loname))
  emit('}')
  emit('')
  emit('static void wowless_imploutputluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  wowless_imploutputluaobject(L, idx, %d, %s);', tid, cstring(loname))
  emit('}')
  emit('')
  emit('static void wowless_imploutputnilableluaobject_%s(lua_State *L, int idx) {', safename(loname))
  emit('  wowless_imploutputnilableluaobject(L, idx, %d, %s);', tid, cstring(loname))
  emit('}')
  emit('')
end

emit('static const struct wowless_uitype wowless_uitypes_by_bit[] = {')
for uname in sorted(uiobjectdata) do
  local bits = uitype_ancestors[uname]
  local terms = {}
  for b in pairs(bits) do
    terms[#terms + 1] = b
  end
  table.sort(terms)
  if #terms > 0 then
    local parts = {}
    for _, b in ipairs(terms) do
      parts[#parts + 1] = 'UINT64_C(1) << ' .. b
    end
    emit('  {%s}, /* %s */', table.concat(parts, ' | '), uname)
  else
    emit('  {0}, /* %s */', uname)
  end
end
emit('};')
emit('')
emit('static int wowless_uiobject_new(lua_State *L) {')
emit('  int id = luaL_checkinteger(L, 1);')
emit('  int bit = luaL_checkinteger(L, 2);')
emit('  struct wowless_uiobject_data *ud =')
emit('      (struct wowless_uiobject_data *)lua_newuserdata(L, sizeof(struct wowless_uiobject_data));')
emit('  ud->marker = &wowless_uiobject_marker;')
emit('  ud->id = id;')
emit('  ud->uitype = &wowless_uitypes_by_bit[bit];')
emit('  return 1;')
emit('}')
emit('')

-- Luaobject method C stubs, generated per SOURCE TYPE (not per concrete type).
-- Virtual type stubs skip the self-check since virtual types can't be instantiated;
-- their stubs are shared across all concrete subtypes that inherit the method.
for loname in sorted(luaobjectdata) do
  local lodata = luaobjectdata[loname]
  if not lodata.impl then
    for mname, mv in sorted(lodata.methods or {}) do
      local inputs = mv.inputs or {}
      local outputs = mv.outputs or {}
      emit('static int stub_lomethod_%s_%s(lua_State *L) {', safename(loname), safename(mname))
      if not lodata.virtual then
        emit('  wowless_stubcheckluaobject_%s(L, 1);', safename(loname))
      end
      for i, inp in ipairs(inputs) do
        local nilable = inp.nilable or inp.default ~= nil
        emit('  %s', dispatch(cinputtypes, inp.type)('stubcheck', nilable, i + 1) .. ';')
      end
      if mv.inputs ~= nil then
        emit('  wowless_stubcheckextraargs(L, %d, %s);', #inputs + 1, cstring(loname .. ':' .. mname))
      end
      for _, out in ipairs(outputs) do
        local val
        if out.stub ~= nil then
          val = out.stub
        elseif out.default ~= nil then
          val = out.default
        elseif not out.nilable or out.stubnotnil then
          val = dispatch(coutdefaults, out.type)
        end
        if val == nil then
          emit('  lua_pushnil(L);')
        else
          dispatch(coutpushers, out.type, val)
        end
      end
      emit('  return %d;', #outputs)
      emit('}')
      emit('')
    end
  end
end

-- Luaobject method C implstubs (impl types like LuaFunctionContainer)
for loname in sorted(luaobjectdata) do
  local lodata = luaobjectdata[loname]
  if not lodata.virtual and lodata.impl then
    for mname in sorted(lodata.methods or {}) do
      emit('static int implstub_lomethod_%s_%s(lua_State *L) {', safename(loname), safename(mname))
      emit('  wowless_implcheckluaobject_%s(L, 1);', safename(loname))
      emit('  return wowless_impl_stub(L);') -- TODO: check inputs and outputs -- issue #667
      emit('}')
      emit('')
    end
  end
end

local function emit_stub_body(key, cfg, inputcheck)
  local allinps = cfg.inputs or {}
  local instride = cfg.instride or 0
  local nsins = #allinps - instride
  for i = 1, nsins do
    emit('  %s', inputcheck(allinps[i], i))
  end
  if instride > 0 then
    emit('  int i, n = lua_gettop(L);')
    emit('  for (i = %d; i <= n; i += %d) {', nsins + 1, instride)
    for j = nsins + 1, #allinps do
      emit('    %s', inputcheck(allinps[j], 'i + ' .. (j - nsins - 1)))
    end
    emit('  }')
  end
  if cfg.inputs ~= nil and instride == 0 then
    emit('  wowless_stubcheckextraargs(L, %d, %s);', nsins, cstring(key))
  end
  local allouts = not cfg.stubnothing and cfg.outputs or {}
  local outstride = cfg.outstride or 0
  local nonstride = #allouts - outstride
  local outs
  if cfg.stuboutstrides ~= nil then
    outs = {}
    for i = 1, nonstride do
      table.insert(outs, allouts[i])
    end
    for _ = 1, cfg.stuboutstrides do
      for j = nonstride + 1, #allouts do
        table.insert(outs, allouts[j])
      end
    end
  else
    outs = allouts
  end
  for _, out in ipairs(outs) do
    local val
    if out.stub ~= nil then
      val = out.stub
    elseif out.default ~= nil then
      val = out.default
    elseif not out.nilable or out.stubnotnil then
      val = dispatch(coutdefaults, out.type)
    end
    if val == nil then
      emit('  lua_pushnil(L);')
    else
      dispatch(coutpushers, out.type, val)
    end
  end
  emit('  return %d;', #outs)
end

local function cpermissive(inp, idx)
  local is_check = dispatch(cinputtypes, inp.type)('is', false, idx)
  local t = type(inp.default)
  local push
  if t == 'boolean' then
    push = ('lua_pushboolean(L, %s)'):format(inp.default and '1' or '0')
  elseif t == 'number' then
    push = ('lua_pushnumber(L, %g)'):format(inp.default)
  elseif t == 'string' then
    push = ('lua_pushstring(L, %s)'):format(cstring(inp.default))
  else
    error('unsupported permissive default type: ' .. t)
  end
  return ('if (!lua_isnoneornil(L, %d) && !%s) { %s; lua_replace(L, %d); }'):format(idx, is_check, push, idx)
end

local function stub_inputcheck(inp, idx)
  if inp.permissive then
    return cpermissive(inp, idx)
  end
  local nilable = inp.nilable or inp.default ~= nil
  return dispatch(cinputtypes, inp.type)('stubcheck', nilable, idx) .. ';'
end

local coutputdefaulttypes = {
  boolean = function(val)
    return string.format('lua_pushboolean(L, %s)', val and '1' or '0')
  end,
  number = function(val)
    return string.format('lua_pushnumber(L, %g)', val)
  end,
  string = function(val)
    return string.format('lua_pushstring(L, %s)', cstring(val))
  end,
}

local function emit_implstub_body(name, v, fn)
  local check_inputs = v.inputs ~= nil
  local check_outputs = v.outputs ~= nil
  local inputs = v.inputs or {}
  local outputs = v.outputs or {}
  local outstride = v.outstride or 0
  local instride = v.instride or 0
  local nfixed = #outputs - outstride
  local nsins = #inputs - instride
  if check_inputs then
    local function check(inp, idx)
      if inp.permissive then
        return cpermissive(inp, idx)
      end
      local nilable = inp.nilable or inp.default ~= nil
      return dispatch(cinputtypes, inp.type)('implcheck', nilable, idx) .. ';'
    end
    local function usagecheck(inp, idx)
      local nilable = inp.nilable or inp.default ~= nil
      return ('if (!%s) return luaL_error(L, %s);'):format(
        dispatch(cinputtypes, inp.type)('is', nilable, idx),
        cstring('Usage: ' .. v.usage)
      )
    end
    local inputcheck = v.usage and usagecheck or check
    for i = 1, nsins do
      emit('  %s', inputcheck(inputs[i], i))
    end
    if instride > 0 then
      emit('  int i, n = lua_gettop(L);')
      emit('  for (i = %d; i <= n; i += %d) {', nsins + 1, instride)
      for j = nsins + 1, #inputs do
        emit('    %s', inputcheck(inputs[j], 'i + ' .. (j - nsins - 1)))
      end
      emit('  }')
    end
    if v.usage then
      for i = 1, nsins do
        emit('  %s', check(inputs[i], i))
      end
      if instride > 0 then
        emit('  for (i = %d; i <= n; i += %d) {', nsins + 1, instride)
        for j = nsins + 1, #inputs do
          emit('    %s', check(inputs[j], 'i + ' .. (j - nsins - 1)))
        end
        emit('  }')
      end
    end
    if instride == 0 then
      emit('  wowless_stubcheckextraargs(L, %d, %s);', nsins, cstring(name))
    end
  end
  if check_outputs then
    emit('  int ret = %s(L);', fn)
    if v.mayreturnnothing then
      emit('  if (ret == 0) return 0;')
    end
    if outstride == 0 then
      emit('  wowless_stubchecknreturns(L, ret, %d, %s);', #outputs, cstring(name))
      for i, out in ipairs(outputs) do
        local nilable = out.nilable
        local otype = out.type
        if out.default ~= nil then
          local push = dispatch(coutputdefaulttypes, type(out.default), out.default)
          emit('  if (lua_isnil(L, %d)) {', i)
          emit('    %s;', push)
          emit('    lua_replace(L, %d);', i)
          emit('  } else {')
          emit('    %s;', dispatch(coutputtypes, otype, false, i))
          emit('  }')
        else
          emit('  %s;', dispatch(coutputtypes, otype, nilable, i))
        end
      end
    else
      if outstride > 1 then
        emit('  if (ret < %d || (ret - %d) %% %d != 0) {', nfixed, nfixed, outstride)
        emit('    return luaL_error(L, "wrong number of return values from %%s", %s);', cstring(name))
        emit('  }')
      end
      for i = 1, nfixed do
        emit('  %s;', dispatch(coutputtypes, outputs[i].type, outputs[i].nilable, i))
      end
      if outstride > 0 then
        emit('  for (int i = %d; i < ret; i += %d) {', nfixed, outstride)
        for j = 1, outstride do
          local out = outputs[nfixed + j]
          emit('    %s;', dispatch(coutputtypes, out.type, out.nilable, string.format('i + %d', j)))
        end
        emit('  }')
      end
    end
    emit('  return ret;')
  else
    emit('  return %s(L);', fn)
  end
end

-- UIObject method C stubs
local uiobjectcimplmakers = {
  getter = function(impl, mv, k, key)
    emit('  wowless_implcheckuiobject_%s(L, 1);', safename(k))
    emit('  wowless_stubcheckextraargs(L, 1, %s);', cstring(key))
    for i, f in ipairs(impl) do
      emit('  lua_getfield(L, 1, %s);', cstring(f.name))
      if mv.outputs[i].type.uiobject then
        emit('  if (!lua_isnil(L, -1)) {')
        emit('    lua_getfield(L, -1, "luarep");')
        emit('    lua_replace(L, -2);')
        emit('  }')
      end
    end
    emit('  return %d;', #impl)
  end,
  none = function(mv, k, key)
    if mv.inputs ~= nil then
      local inputs_with_self = { { type = { uiobject = k } } }
      for _, inp in ipairs(mv.inputs) do
        table.insert(inputs_with_self, inp)
      end
      emit_stub_body(key, Mixin({}, mv, { inputs = inputs_with_self }), stub_inputcheck)
    else
      emit('  wowless_stubcheckuiobject_%s(L, 1);', safename(k))
      emit_stub_body(key, mv, stub_inputcheck)
    end
  end,
  setter = function(impl, mv, k, key)
    emit('  wowless_implcheckuiobject_%s(L, 1);', safename(k))
    for i, inp in ipairs(mv.inputs) do
      local nilable = inp.nilable or inp.default ~= nil
      emit('  %s;', dispatch(cinputtypes, inp.type)('implcheck', nilable, i + 1))
    end
    emit('  wowless_stubcheckextraargs(L, %d, %s);', #impl + 1, cstring(key))
    for i, f in ipairs(impl) do
      local spec = mv.inputs[i]
      if spec.default ~= nil then
        emit('  if (lua_isnoneornil(L, %d)) {', i + 1)
        if type(spec.default) == 'boolean' then
          emit('    lua_pushboolean(L, %d);', spec.default and 1 or 0)
        elseif type(spec.default) == 'number' then
          emit('    lua_pushnumber(L, %g);', spec.default)
        else
          error('unsupported setter default type: ' .. type(spec.default))
        end
        emit('  } else {')
        emit('    lua_pushvalue(L, %d);', i + 1)
        emit('  }')
      else
        emit('  lua_pushvalue(L, %d);', i + 1)
      end
      emit('  lua_setvaluetaint(L, -1, NULL);')
      emit('  lua_setfield(L, 1, %s);', cstring(f.name))
    end
    emit('  return 0;')
  end,
}
for key, entry in sorted(eligible_uimethods) do
  local k, mk, mv = entry.k, entry.mk, entry.mv
  if entry.implimpl then
    local implimpl = entry.implimpl
    local fn = implimpl.nobubblewrap and 'wowless_impl_stub_nobubblewrap' or 'wowless_impl_stub'
    local inputs = { { type = { uiobject = k } } }
    for _, inp in ipairs(mv.inputs or {}) do
      table.insert(inputs, inp)
    end
    emit('static int implstub_uiimpl_%s_%s(lua_State *L) {', safename(k), safename(mk))
    emit_implstub_body(key, {
      inputs = inputs,
      instride = mv.instride,
      mayreturnnothing = mv.mayreturnnothing,
      outputs = mv.outputs,
      outstride = mv.outstride,
    }, fn)
    emit('}')
    emit('')
  else
    emit('static int stub_uimethod_%s_%s(lua_State *L) {', safename(k), safename(mk))
    if mv.secureonly then
      emit('  if (wowless_forbidden(L)) return 0;')
    end
    dispatch(uiobjectcimplmakers, mv.impl or 'none', mv, k, key)
    emit('}')
    emit('')
  end
end

local ns_entries = {}
local global_entries = {}
for k, v in pairs(parseYaml('data/products/' .. product .. '/apis.yaml')) do
  local impl = v.impl and ensureimpl(v.impl)
  if not impl or not impl.nowrap then
    emit('static int api_%s(lua_State *L) {', safename(k))
    if v.protected then
      emit('  if (wowless_forbidden(L)) return 0;')
    end
    if v.unsupported then
      emit('  return luaL_error(L, "Script_%s: API unsupported in this version of World of Warcraft.");', k)
    elseif not v.impl then
      local inputcheck
      if v.usage then
        inputcheck = function(inp, idx)
          local nilable = inp.nilable or inp.default ~= nil
          return ('if (!%s) return luaL_error(L, %s);'):format(
            dispatch(cinputtypes, inp.type)('is', nilable, idx),
            cstring('Usage: ' .. v.usage)
          )
        end
      else
        inputcheck = stub_inputcheck
      end
      emit_stub_body(k, v, inputcheck)
    else
      local fn = impl.nobubblewrap and 'wowless_impl_stub_nobubblewrap' or 'wowless_impl_stub'
      emit_implstub_body(k, v, fn)
    end
    emit('}')
    emit('')
  end
  local e = {
    impldata = impl,
    chunkname = impl and impl.src or k,
    secureonly = v.secureonly,
    sn = safename(k),
  }
  local dot = k:find('%.')
  if dot then
    local ns = k:sub(1, dot - 1)
    local shortname = k:sub(dot + 1)
    if not ns_entries[ns] then
      ns_entries[ns] = {}
    end
    ns_entries[ns][shortname] = e
  else
    global_entries[k] = e
  end
end

local function emit_stub_entry_statics(sn, entry)
  if entry.impldata then
    local impldata = entry.impldata
    local mods = impldata.modules or {}
    local sqls_list = impldata.sqls or {}
    if #mods > 0 then
      local parts = {}
      for _, m in ipairs(mods) do
        table.insert(parts, cstring(m))
      end
      emit('static const char *const implmods_%s[] = {%s, nullptr};', sn, table.concat(parts, ', '))
    end
    if #sqls_list > 0 then
      local parts = {}
      for _, s in ipairs(sqls_list) do
        table.insert(parts, cstring(s))
      end
      emit('static const char *const implsqls_%s[] = {%s, nullptr};', sn, table.concat(parts, ', '))
    end
    emit(
      'static const wowless_impl_data impldata_%s = {%s, %d, %s, %s, %s};',
      sn,
      cstring(impldata.impl),
      #impldata.impl,
      cstring(entry.chunkname),
      #mods > 0 and ('implmods_' .. sn) or 'nullptr',
      #sqls_list > 0 and ('implsqls_' .. sn) or 'nullptr'
    )
  end
end

local function emit_stub_entry(indent, name, entry)
  if entry.impldata then
    local impldata = entry.impldata
    local func = impldata.nowrap and 'nullptr' or ('api_' .. entry.sn)
    emit('%s{%s, %s, %d, &impldata_%s},', indent, cstring(name), func, entry.secureonly and 1 or 0, entry.sn)
  else
    emit('%s{%s, api_%s, %d, nullptr},', indent, cstring(name), entry.sn, entry.secureonly and 1 or 0)
  end
end

for _, entry in sorted(global_entries) do
  emit_stub_entry_statics(entry.sn, entry)
end
for ns in sorted(ns_entries) do
  for _, entry in sorted(ns_entries[ns]) do
    emit_stub_entry_statics(entry.sn, entry)
  end
end
if next(global_entries) or next(ns_entries) then
  emit('')
end

emit('static const wowless_stub_entry stubs_global[] = {')
for name, entry in sorted(global_entries) do
  emit_stub_entry('  ', name, entry)
end
emit('  {nullptr, nullptr, 0, nullptr}')
emit('};')
emit('')

for ns in sorted(ns_entries) do
  emit('static const wowless_stub_entry stubs_ns_%s[] = {', safename(ns))
  for name, entry in sorted(ns_entries[ns]) do
    emit_stub_entry('  ', name, entry)
  end
  emit('  {nullptr, nullptr, 0, nullptr}')
  emit('};')
  emit('')
end

emit('static const wowless_ns_entry stubs_ns[] = {')
for ns in sorted(ns_entries) do
  emit('  {%s, stubs_ns_%s},', cstring(ns), safename(ns))
end
emit('  {nullptr, nullptr}')
emit('};')
emit('')

emit('static const wowless_stubs_spec stubs_spec = {')
emit('  stubs_global,')
emit('  stubs_ns,')
emit('};')
emit('')
-- Luaobject method impldata statics for impl types
for loname in sorted(luaobjectdata) do
  local lodata = luaobjectdata[loname]
  if not lodata.virtual and lodata.impl then
    for mname in sorted(lodata.methods or {}) do
      local sn = string.format('lomethod_%s_%s', safename(loname), safename(mname))
      local impl_src = string.format('return (...).methods[%q]', mname)
      emit('static const char *const implmods_%s[] = {%s, nullptr};', sn, cstring(lodata.impl))
      emit(
        'static const wowless_impl_data impldata_%s = {%s, %d, %s, implmods_%s, nullptr};',
        sn,
        cstring(impl_src),
        #impl_src,
        cstring(loname .. ':' .. mname),
        sn
      )
    end
  end
end
emit('')

-- Per-type luaobject method entry arrays; only direct (non-inherited) methods are
-- listed per type. Inherited methods are picked up via luaobjects.lua inheritance.
-- Virtual types are also included so their stubs can be shared across subtypes.
for loname in sorted(luaobjectdata) do
  local lodata = luaobjectdata[loname]
  emit('static const wowless_stub_entry lo_methods_%s[] = {', safename(loname))
  if not lodata.virtual and lodata.impl then
    for mname in sorted(lodata.methods or {}) do
      local sn = string.format('lomethod_%s_%s', safename(loname), safename(mname))
      emit('  {%s, implstub_%s, 0, &impldata_%s},', cstring(mname), sn, sn)
    end
  else
    for mname in sorted(lodata.methods or {}) do
      local sn = string.format('lomethod_%s_%s', safename(loname), safename(mname))
      emit('  {%s, stub_%s, 0, nullptr},', cstring(mname), sn)
    end
  end
  emit('  {nullptr, nullptr, 0, nullptr}')
  emit('};')
  emit('')
end

-- Luaobject type registry (all types including virtual, for method stub sharing)
emit('static const wowless_luaobject_type_entry lo_types[] = {')
for loname in sorted(luaobjectdata) do
  emit('  {%s, %d, lo_methods_%s},', cstring(loname), luaobject_typeids[loname], safename(loname))
end
emit('  {nullptr, 0, nullptr}')
emit('};')
emit('')
-- UIObject host impl data statics
for key, entry in sorted(eligible_uimethods) do
  if not entry.implimpl then
    local sn = safename(entry.k) .. '_' .. safename(entry.mk)
    local d = dispatch(uiobjectimplmakers, entry.mv.impl or 'none', entry.mv, entry.k)
    emit(
      'static const wowless_impl_data host_impldata_%s = {%s, %d, %s, nullptr, nullptr};',
      sn,
      cstring(d.impl),
      #d.impl,
      cstring(key)
    )
  end
end
-- UIObject impl method impldata statics
for key, entry in sorted(eligible_uimethods) do
  if entry.implimpl then
    local k, mk = entry.k, entry.mk
    local implimpl = entry.implimpl
    local sn = 'uiimpl_' .. safename(k) .. '_' .. safename(mk)
    emit_stub_entry_statics(sn, { impldata = implimpl, chunkname = implimpl.src or key })
  end
end
emit('')
-- UIObject method entry array
emit('static const struct wowless_uiobject_method_entry uiobject_method_entries[] = {')
for key, entry in sorted(eligible_uimethods) do
  local k, mk = entry.k, entry.mk
  if entry.implimpl then
    local sn = 'uiimpl_' .. safename(k) .. '_' .. safename(mk)
    emit('  {%s, implstub_uiimpl_%s_%s, &impldata_%s, 1},', cstring(key), safename(k), safename(mk), sn)
  else
    local sn = safename(k) .. '_' .. safename(mk)
    emit('  {%s, stub_uimethod_%s_%s, &host_impldata_%s, 0},', cstring(key), safename(k), safename(mk), sn)
  end
end
emit('  {nullptr, nullptr, nullptr, 0}')
emit('};')
emit('')
for k, e in sorted(eventcfg) do
  local payload = e.payload
  local stride = e.stride or 0
  local nfixed = #payload - stride
  emit('static int eventcheck_%s(lua_State *L) {', safename(k))
  emit('  int n = lua_gettop(L);')
  if stride > 1 then
    emit('  if (n < %d || (n - %d) %% %d != 0) {', nfixed, nfixed, stride)
    emit(
      '    return luaL_error(L, "wrong number of return values to %%q: want stride %d, got %%d", %s, n);',
      stride,
      cstring(k)
    )
    emit('  }')
  elseif stride == 0 then
    emit('  wowless_stubchecknreturns(L, n, %d, %s);', nfixed, cstring(k))
  end
  for i = 1, nfixed do
    local out = payload[i]
    local nilable = out.nilable
    emit('  %s;', dispatch(coutputtypes, out.type, nilable, i))
  end
  if stride > 0 then
    emit('  for (int i = %d; i < n; i += %d) {', nfixed, stride)
    for j = 1, stride do
      local out = payload[nfixed + j]
      local nilable = out.nilable
      emit('    %s;', dispatch(coutputtypes, out.type, nilable, string.format('i + %d', j)))
    end
    emit('  }')
  end
  emit('  return n;')
  emit('}')
  emit('')
end
emit('static const luaL_Reg eventcheck_reg[] = {')
for k in sorted(eventcfg) do
  emit('  {%s, eventcheck_%s},', cstring(k), safename(k))
end
emit('  {nullptr, nullptr}')
emit('};')
emit('')
emit('extern "C" int luaopen_build_products_%s_stubs(lua_State *L) {', product)
emit('  lua_newtable(L);')
emit('  lua_pushlightuserdata(L, static_cast<void *>(const_cast<wowless_stubs_spec *>(&stubs_spec)));')
emit('  lua_pushcclosure(L, wowless_load_stubs, 1);')
emit('  lua_setfield(L, -2, "load");')
emit('  lua_pushcfunction(L, wowless_uiobject_new);')
emit('  lua_setfield(L, -2, "new");')
emit('  lua_pushlightuserdata(L, static_cast<void *>(const_cast<wowless_luaobject_type_entry *>(lo_types)));')
emit('  lua_pushcclosure(L, wowless_load_luaobject_stubs, 1);')
emit('  lua_setfield(L, -2, "loadluaobjects");')
emit('  lua_pushlightuserdata(L, (void *)uiobject_method_entries);')
emit('  lua_pushcclosure(L, wowless_load_uiobject_method_stubs, 1);')
emit('  lua_setfield(L, -2, "loaduiobjectmethods");')
emit('  lua_pushlightuserdata(L, (void *)eventcheck_reg);')
emit('  lua_pushcclosure(L, wowless_load_eventcheck_stubs, 1);')
emit('  lua_setfield(L, -2, "loadevents");')
emit('  return 1;')
emit('}')

local cf = assert(io.open(args.coutput, 'w'))
cf:write(table.concat(lines, '\n'))
cf:write('\n')
cf:close()

local outfn = args.output or ('build/products/' .. args.product .. '/data.lua')
local tu = require('tools.util')
tu.writedeps(outfn, deps)
require('pl.file').write(outfn, tu.returntable(data))
