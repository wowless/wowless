local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:option('--sqls', 'sqls file')
  parser:option('-o --output', 'output file')
  parser:option('--coutput', 'C stubs output file')
  return parser:parse()
end)()

local product = args.product

local deps = {} -- accumulated during runtime

local function parseYaml(f)
  deps[f] = true
  return (assert(require('wowapi.yaml').parseFile(f)))
end
local function readFile(f)
  deps[f] = true
  return (assert(require('pl.file').read(f)))
end
local plprettywrite = require('pl.pretty').write
local Mixin = require('wowless.util').mixin
local sorted = require('pl.tablex').sort

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
    return plprettywrite(value, '')
  else
    error('unsupported stub value type ' .. ty)
  end
end

local specDefault = (function()
  local defaultOutputs = {
    boolean = 'false',
    FileAsset = '1',
    ['function'] = 'function() end',
    ['nil'] = 'nil',
    number = '1',
    oneornil = 'nil',
    string = '\'\'',
    table = '{}',
    unit = '\'player\'',
    unknown = 'nil',
  }
  local structureDefaults = {}
  local specDefault
  local function valstruct(name)
    if not structureDefaults[name] then
      local st = assert(structures[name], name)
      local t = {}
      for fname, field in sorted(st.fields) do
        local v = specDefault(field)
        if v ~= 'nil' then
          table.insert(t, ('[%q]=%s'):format(fname, v))
        end
      end
      local str = '{' .. table.concat(t, ',') .. '}'
      structureDefaults[name] = st.mixin and ('gencode.Mixin(%s,%q)'):format(str, st.mixin) or str
    end
    return structureDefaults[name]
  end
  function specDefault(spec)
    if spec.stub ~= nil then
      return valstr(spec.stub)
    end
    if spec.default ~= nil then
      return valstr(spec.default)
    end
    if spec.nilable and not spec.stubnotnil then
      return 'nil'
    end
    local ty = assert(spec.type, 'spec missing a type')
    if defaultOutputs[ty] then
      return defaultOutputs[ty]
    end
    if ty.stringenum then
      local least
      for k in pairs(stringenums[ty.stringenum]) do
        least = (least == nil or k < least) and k or least
      end
      return ('%q'):format(least)
    end
    if ty.arrayof then
      return '{' .. specDefault({ type = ty.arrayof }) .. '}'
    end
    if ty.structure then
      return valstruct(ty.structure)
    end
    if ty.enum then
      assert(globals.Enum[ty.enum], 'missing enum ' .. ty.enum)
      local meta = assert(globals.Enum[ty.enum .. 'Meta'], 'missing meta enum for ' .. ty.enum)
      local min = assert(meta.MinValue, 'missing MinValue in meta for ' .. ty.enum)
      return valstr(min)
    end
    if ty.uiobject then
      return ('gencode.CreateUIObject(%q).luarep'):format(ty.uiobject:lower())
    end
    if ty.luaobject then
      return ('gencode.CreateLuaObject(%q).luarep'):format(ty.luaobject)
    end
    error('unexpected type: ' .. require('pl.pretty').write(ty))
  end
  return specDefault
end)()

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

local function stubby(mv, skip0)
  local t = { 'local gencode=...;' }
  local ins = mv.inputs or {}
  local nsins = #ins - (mv.instride or 0)
  for i = 1, #ins do
    table.insert(t, 'local spec' .. i .. '=' .. plprettywrite(mv.inputs[i], '') .. ';')
  end
  table.insert(t, 'return function(')
  local a = {}
  if skip0 then
    table.insert(a, '_')
  end
  for i = 1, nsins do
    table.insert(a, 'arg' .. i)
  end
  if mv.instride then
    table.insert(a, '...')
  end
  table.insert(t, table.concat(a, ','))
  table.insert(t, ')')
  for i = 1, nsins do
    table.insert(t, 'gencode.Check(spec' .. i .. ',arg' .. i .. ');')
  end
  if mv.instride then
    table.insert(t, 'for i=1,select("#",...),' .. mv.instride .. ' do ')
    table.insert(t, 'local arg' .. nsins + 1)
    for i = nsins + 2, #ins do
      table.insert(t, ',arg' .. i)
    end
    table.insert(t, '=select(i,...);')
    for i = nsins + 1, #ins do
      table.insert(t, 'gencode.Check(spec' .. i .. ',arg' .. i .. ');')
    end
    table.insert(t, 'end ')
  end
  local outs = mv.outputs or {}
  if #outs > 0 and not mv.stubnothing then
    table.insert(t, 'return ')
    local rets = {}
    local nonstride = #outs - (mv.outstride or 0)
    for i = 1, nonstride do
      table.insert(rets, specDefault(outs[i]))
    end
    for _ = 1, mv.stuboutstrides or 1 do
      for j = nonstride + 1, #outs do
        table.insert(rets, specDefault(outs[j]))
      end
    end
    table.insert(t, table.concat(rets, ','))
  end
  table.insert(t, ' end')
  return {
    impl = table.concat(t),
    modules = { 'gencode' },
    secureonly = mv.secureonly,
  }
end

local implimpls = {
  delegate = function(impl)
    return {
      impl = 'return debug.newcfunction(' .. impl .. ')',
      nobubblewrap = true,
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
      nobubblewrap = impl.nobubblewrap,
    }
  end,
  moduledelegate = function(impl, name)
    return {
      impl = ('return (...)[%q]'):format(impl['function'] or name),
      modules = { impl.name },
    }
  end,
  stdlib = function(path)
    return {
      impl = 'return ' .. path,
      nobubblewrap = true,
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

local function mkapi(apicfg)
  if apicfg.impl then
    local impl = ensureimpl(apicfg.impl)
    return {
      impl = impl.impl,
      inputs = not impl.nobubblewrap and apicfg.inputs or nil,
      instride = apicfg.instride,
      mayreturnnothing = apicfg.mayreturnnothing,
      modules = impl.modules,
      nobubblewrap = impl.nobubblewrap,
      outputs = not impl.nobubblewrap and apicfg.outputs or nil,
      outstride = apicfg.outstride,
      sqls = impl.sqls,
      src = impl.src,
      usage = apicfg.usage,
    }
  end
end

local rawapis = parseYaml('data/products/' .. product .. '/apis.yaml')
local apis = {}
for k, v in pairs(rawapis) do
  apis[k] = mkapi(v)
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

local events = {}
for k, v in pairs(parseYaml('data/products/' .. product .. '/events.yaml')) do
  local t = {}
  for _, f in ipairs(v.payload) do
    table.insert(t, specDefault(f))
  end
  events[k] = {
    callback = v.callback,
    noscript = v.noscript,
    payload = v.payload,
    restricted = v.restricted,
    stride = v.stride,
    stub = 'return ' .. table.concat(t, ','),
  }
end

local uiobjectdata = parseYaml('data/products/' .. product .. '/uiobjects.yaml')
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
      impl = readFile(src),
      modules = modules,
      sqls = impl.sqls,
      src = '@./' .. src,
    }
  end,
  moduledelegate = function(impl, k)
    return {
      impl = ('return (...)[%q]'):format(k:sub(k:find('/') + 1)),
      modules = { impl.name },
    }
  end,
}
local uiobjectimplmakers = {
  getter = function(impl, mv)
    local t = { 'local gencode=...;' }
    for i in ipairs(impl) do
      table.insert(t, 'local spec' .. i .. '=' .. plprettywrite(mv.outputs[i], '') .. ';')
    end
    table.insert(t, 'return function(self)return ')
    for i, f in ipairs(impl) do
      table.insert(t, (i == 1 and '' or ',') .. 'gencode.Check(spec' .. i .. ',self.' .. f.name .. ',true)')
    end
    table.insert(t, 'end')
    return {
      impl = table.concat(t),
      modules = { 'gencode' },
    }
  end,
  none = function(mv)
    return stubby(mv, true)
  end,
  setter = function(impl, mv)
    local t = { 'local gencode=...;' }
    for i in ipairs(impl) do
      table.insert(t, 'local spec' .. i .. '=' .. plprettywrite(mv.inputs[i], '') .. ';')
    end
    table.insert(t, 'return function(self')
    for _, f in ipairs(impl) do
      table.insert(t, ',')
      table.insert(t, f.name)
    end
    table.insert(t, ')')
    for i, f in ipairs(impl) do
      table.insert(t, 'self.')
      table.insert(t, f.name)
      table.insert(t, '=gencode.Check(spec')
      table.insert(t, tostring(i))
      table.insert(t, ',')
      table.insert(t, f.name)
      table.insert(t, ');')
    end
    table.insert(t, 'end')
    return {
      impl = table.concat(t),
      modules = { 'gencode' },
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
      impl = table.concat(t),
      modules = { 'gencode' },
    }
  end,
  uiobjectimpl = function(impl, mv)
    local implimpl = dispatch(uiobjectimplimplmakers, uiobjectimpl[impl], impl)
    return {
      impl = implimpl.impl,
      inputs = mv.inputs,
      instride = mv.instride,
      mayreturnnothing = mv.mayreturnnothing,
      modules = implimpl.modules,
      outputs = mv.outputs,
      outstride = mv.outstride,
      sqls = implimpl.sqls,
      src = implimpl.src,
    }
  end,
}
local uiobjects = {}
for k, v in pairs(uiobjectdata) do
  local constructor = { 'local gencode=...;return function()return{' }
  for fk, fv in sorted(mkuiobjectinit(k)) do
    table.insert(constructor, ('%s=%s,'):format(fk, fv))
  end
  table.insert(constructor, '}end')
  local methods = {}
  for mk, mv in pairs(v.methods) do
    methods[mk] = dispatch(uiobjectimplmakers, mv.impl or 'none', mv)
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
  }
end

local luaobjects = {}
do
  local luaobjectdata = parseYaml('data/products/' .. product .. '/luaobjects.yaml')
  for k, v in pairs(luaobjectdata) do
    local methods = {}
    if v.impl then
      for mk in pairs(v.methods or {}) do
        methods[mk] = {
          impl = ('return (...).methods[%q]'):format(mk),
          modules = { v.impl },
        }
      end
    else
      for mk, mv in pairs(v.methods or {}) do
        methods[mk] = stubby(mv, true)
      end
    end
    luaobjects[k] = {
      impl = v.impl,
      inherits = v.inherits,
      methods = methods,
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
  apis = apis,
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

if args.coutput then
  local function safename(s)
    return s:gsub('[%.:]', '_')
  end

  local function cstring(s)
    return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"') .. '"'
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
    unknown = function()
      return nil
    end,
  }

  local used_structures = {}
  local used_arrayofs = {}
  local used_luaobjects = {}
  local used_stringenums = {}
  local used_uiobjects = {}
  local cinputtypes
  cinputtypes = {
    arrayof = function(inner)
      local inner_type = dispatch(cinputtypes, inner)
      used_arrayofs[inner_type] = inner
      return 'arrayof_' .. inner_type
    end,
    boolean = function()
      return 'boolean'
    end,
    enum = function()
      return 'enum'
    end,
    FileAsset = function()
      return 'string'
    end,
    ['function'] = function()
      return 'function'
    end,
    number = function()
      return 'number'
    end,
    string = function()
      return 'string'
    end,
    stringenum = function(name)
      used_stringenums[name] = true
      return 'stringenum_' .. safename(name)
    end,
    structure = function(name)
      local st = assert(structures[name], name)
      for _, field in pairs(st.fields) do
        dispatch(cinputtypes, field.type)
      end
      used_structures[name] = true
      return 'struct_' .. safename(name)
    end,
    table = function()
      return 'table'
    end,
    uiAddon = function()
      return 'string'
    end,
    luaobject = function(name)
      used_luaobjects[name] = true
      return 'luaobject_' .. safename(name)
    end,
    uiobject = function(name)
      used_uiobjects[name] = true
      return 'uiobject_' .. safename(name)
    end,
    unit = function()
      return 'unit'
    end,
    unknown = function()
      return 'unknown'
    end,
  }

  local function is_eligible(apicfg)
    if apicfg.impl then
      return false
    end
    if next(apicfg.outputs or {}) and not apicfg.stubnothing then
      for _, out in ipairs(apicfg.outputs) do
        dispatch(coutdefaults, out.type)
      end
    end
    for _, inp in ipairs(apicfg.inputs or {}) do
      dispatch(cinputtypes, inp.type)
    end
    return true
  end

  local lines = {}
  local function emit(fmt, ...)
    table.insert(lines, string.format(fmt, ...))
  end

  emit('#include "lua.h"')
  emit('#include "lauxlib.h"')
  emit('#include "wowless/stubs.h"')
  emit('#include "wowless/typecheck.h"')
  emit('')

  local eligible = {}
  for k, v in sorted(rawapis) do
    if is_eligible(v) then
      table.insert(eligible, { name = k, cfg = v })
    end
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
      emit('  wowless_stubcreateluaobject(L, %s, %d);', cstring(name), #name)
    end,
    table = lua_value_emitters.table,
    uiobject = function(name, _)
      emit('  wowless_stubcreateuiobject(L, %s, %d);', cstring(name), #name)
    end,
  }

  for sname in sorted(used_structures) do
    emit('static void wowless_stubcheckstruct_%s(lua_State *L, int idx);', safename(sname))
    emit('static void wowless_stubchecknilablestruct_%s(lua_State *L, int idx);', safename(sname))
  end
  if next(used_structures) then
    emit('')
  end
  for atype in sorted(used_arrayofs) do
    emit('static void wowless_stubcheckarrayof_%s(lua_State *L, int idx);', atype)
    emit('static void wowless_stubchecknilablearrayof_%s(lua_State *L, int idx);', atype)
  end
  if next(used_arrayofs) then
    emit('')
  end
  for lname in sorted(used_luaobjects) do
    emit('static void wowless_stubcheckluaobject_%s(lua_State *L, int idx);', safename(lname))
    emit('static void wowless_stubchecknilableluaobject_%s(lua_State *L, int idx);', safename(lname))
  end
  if next(used_luaobjects) then
    emit('')
  end
  for sename in sorted(used_stringenums) do
    emit('static void wowless_stubcheckstringenum_%s(lua_State *L, int idx);', safename(sename))
    emit('static void wowless_stubchecknilablestringenum_%s(lua_State *L, int idx);', safename(sename))
  end
  if next(used_stringenums) then
    emit('')
  end
  for uname in sorted(used_uiobjects) do
    emit('static void wowless_stubcheckuiobject_%s(lua_State *L, int idx);', safename(uname))
    emit('static void wowless_stubchecknilableuiobject_%s(lua_State *L, int idx);', safename(uname))
  end
  if next(used_uiobjects) then
    emit('')
  end

  for sname in sorted(used_structures) do
    local st = assert(structures[sname], sname)
    emit('static void wowless_stubcheckstruct_%s(lua_State *L, int idx) {', safename(sname))
    emit('  idx = lua_absindex(L, idx);')
    emit('  wowless_stubchecktable(L, idx);')
    for fname, field in sorted(st.fields) do
      local field_nilable = field.nilable or field.default ~= nil
      local ftype = field.type
      emit('  lua_pushliteral(L, %s);', cstring(fname))
      emit('  lua_rawget(L, idx);')
      emit('  wowless_stubcheck%s%s(L, -1);', field_nilable and 'nilable' or '', dispatch(cinputtypes, ftype))
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

  for atype, inner in sorted(used_arrayofs) do
    emit('static void wowless_stubcheckarrayof_%s(lua_State *L, int idx) {', atype)
    emit('  int i, n;')
    emit('  idx = lua_absindex(L, idx);')
    emit('  wowless_stubchecktable(L, idx);')
    emit('  n = (int)lua_objlen(L, idx);')
    emit('  for (i = 1; i <= n; i++) {')
    emit('    lua_rawgeti(L, idx, i);')
    emit('    wowless_stubcheck%s(L, -1);', dispatch(cinputtypes, inner))
    emit('    lua_pop(L, 1);')
    emit('  }')
    emit('}')
    emit('')
    emit('static void wowless_stubchecknilablearrayof_%s(lua_State *L, int idx) {', atype)
    emit('  if (!lua_isnoneornil(L, idx)) {')
    emit('    wowless_stubcheckarrayof_%s(L, idx);', atype)
    emit('  }')
    emit('}')
    emit('')
  end

  for lname in sorted(used_luaobjects) do
    emit('static void wowless_stubcheckluaobject_%s(lua_State *L, int idx) {', safename(lname))
    emit('  wowless_stubcheckluaobject(L, idx, %s, %d);', cstring(lname), #lname)
    emit('}')
    emit('')
    emit('static void wowless_stubchecknilableluaobject_%s(lua_State *L, int idx) {', safename(lname))
    emit('  wowless_stubchecknilableluaobject(L, idx, %s, %d);', cstring(lname), #lname)
    emit('}')
    emit('')
  end

  for sename in sorted(used_stringenums) do
    emit('static void wowless_stubcheckstringenum_%s(lua_State *L, int idx) {', safename(sename))
    emit('  wowless_stubcheckstringenum(L, idx, %s, %d);', cstring(sename), #sename)
    emit('}')
    emit('')
    emit('static void wowless_stubchecknilablestringenum_%s(lua_State *L, int idx) {', safename(sename))
    emit('  wowless_stubchecknilablestringenum(L, idx, %s, %d);', cstring(sename), #sename)
    emit('}')
    emit('')
  end

  for uname in sorted(used_uiobjects) do
    local target = uname:lower()
    emit('static void wowless_stubcheckuiobject_%s(lua_State *L, int idx) {', safename(uname))
    emit('  wowless_stubcheckuiobject(L, idx, %s, %d);', cstring(target), #target)
    emit('}')
    emit('')
    emit('static void wowless_stubchecknilableuiobject_%s(lua_State *L, int idx) {', safename(uname))
    emit('  wowless_stubchecknilableuiobject(L, idx, %s, %d);', cstring(target), #target)
    emit('}')
    emit('')
  end

  for _, entry in ipairs(eligible) do
    local k, v = entry.name, entry.cfg
    emit('static int stub_%s(lua_State *L) {', safename(k))
    local allinps = v.inputs or {}
    local instride = v.instride or 0
    local nsins = #allinps - instride
    local function check(inp, idx)
      local nilable = inp.nilable or inp.default ~= nil
      return ('wowless_stubcheck%s%s(L, %s);'):format(nilable and 'nilable' or '', dispatch(cinputtypes, inp.type), idx)
    end
    for i = 1, nsins do
      emit('  %s', check(allinps[i], i))
    end
    if instride > 0 then
      emit('  int i, n = lua_gettop(L);')
      emit('  for (i = %d; i <= n; i += %d) {', nsins + 1, instride)
      for j = nsins + 1, #allinps do
        emit('    %s', check(allinps[j], 'i + ' .. (j - nsins - 1)))
      end
      emit('  }')
    end
    local allouts = not v.stubnothing and v.outputs or {}
    local outstride = v.outstride or 0
    local nonstride = #allouts - outstride
    local stuboutstrides = v.stuboutstrides
    local outs
    if stuboutstrides ~= nil then
      outs = {}
      for i = 1, nonstride do
        table.insert(outs, allouts[i])
      end
      for _ = 1, stuboutstrides do
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
    emit('}')
    emit('')
  end

  local ns_entries = {}
  local global_entries = {}
  for _, entry in ipairs(eligible) do
    local dot = entry.name:find('%.')
    if dot then
      local ns = entry.name:sub(1, dot - 1)
      local shortname = entry.name:sub(dot + 1)
      if not ns_entries[ns] then
        ns_entries[ns] = {}
      end
      ns_entries[ns][shortname] = not not entry.cfg.secureonly
    else
      global_entries[entry.name] = not not entry.cfg.secureonly
    end
  end

  local function emit_stub_entries(array_name, entries, prefix)
    emit('static const struct wowless_stub_entry %s[] = {', array_name)
    for name, secureonly in sorted(entries) do
      emit('  {%s, stub_%s, %d},', cstring(name), safename(prefix .. name), secureonly and 1 or 0)
    end
    emit('  {NULL, NULL, 0}')
    emit('};')
    emit('')
  end

  for ns in sorted(ns_entries) do
    emit_stub_entries('stubs_' .. safename(ns), ns_entries[ns], ns .. '.')
  end

  emit_stub_entries('global_stubs', global_entries, '')

  emit('static const struct wowless_ns_entry ns_stubs[] = {')
  for ns in sorted(ns_entries) do
    emit('  {%s, stubs_%s},', cstring(ns), safename(ns))
  end
  emit('  {NULL, NULL}')
  emit('};')
  emit('')

  emit('static int stub_loader(lua_State *L) {')
  emit('  wowless_load_stubs(L, global_stubs, ns_stubs);')
  emit('  return 2;')
  emit('}')
  emit('')
  emit('int luaopen_build_products_%s_stubs(lua_State *L) {', product)
  emit('  lua_pushcfunction(L, stub_loader);')
  emit('  return 1;')
  emit('}')

  local cf = assert(io.open(args.coutput, 'w'))
  cf:write(table.concat(lines, '\n'))
  cf:write('\n')
  cf:close()
end

local outfn = args.output or ('build/products/' .. args.product .. '/data.lua')
local tu = require('tools.util')
tu.writedeps(outfn, deps)
require('pl.file').write(outfn, tu.returntable(data))
