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
      impl = 'return ' .. impl,
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
    }
  end,
  moduledelegate = function(impl, name)
    return {
      impl = ('return (...)[%q]'):format(impl['function'] or name),
      modules = { impl.name },
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
    local ic = assert(implcfg[apicfg.impl], 'missing impl ' .. apicfg.impl)
    if ic.stdlib then
      return { stdlib = ic.stdlib }
    else
      local impl = ensureimpl(apicfg.impl)
      return {
        impl = impl.impl,
        inputs = apicfg.inputs,
        instride = apicfg.instride,
        mayreturnnothing = apicfg.mayreturnnothing,
        modules = impl.modules,
        outputs = apicfg.outputs,
        outstride = apicfg.outstride,
        sqls = impl.sqls,
        src = impl.src,
        usage = apicfg.usage,
      }
    end
  else
    return stubby(apicfg)
  end
end

local apis = {}
for k, v in pairs(parseYaml('data/products/' .. product .. '/apis.yaml')) do
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
  xml = parseYaml('data/products/' .. product .. '/xml.yaml'),
}

local outfn = args.output or ('build/products/' .. args.product .. '/data.lua')
local tu = require('tools.util')

-- C stub code generation (must run before writing data.lua to set cstub flags)
if args.coutput then
  local nilables = {
    gender = true,
    ['nil'] = true,
    oneornil = true,
  }

  local function is_c_eligible_type(ty)
    if type(ty) == 'string' then
      local ok = {
        any = true,
        boolean = true,
        FileAsset = true,
        ['function'] = true,
        gender = true,
        ['nil'] = true,
        number = true,
        oneornil = true,
        string = true,
        table = true,
        tostring = true,
        unknown = true,
        userdata = true,
      }
      return ok[ty] == true
    end
    if ty.enum or ty.stringenum then
      return true
    end
    if ty.structure then
      local st = structures[ty.structure]
      if not st then
        return false
      end
      if st.mixin then
        return false
      end
      for _, field in pairs(st.fields) do
        if not is_c_eligible_type(field.type) then
          return false
        end
      end
      return true
    end
    if ty.arrayof then
      return is_c_eligible_type(ty.arrayof)
    end
    return false
  end

  local function is_c_eligible_output(spec)
    if spec.stub ~= nil then
      return true -- literal value
    end
    if spec.default ~= nil then
      return true -- literal value
    end
    if spec.nilable and not spec.stubnotnil then
      return true -- nil
    end
    return is_c_eligible_type(spec.type)
  end

  local function is_c_eligible_stub(apicfg)
    -- Only stubs (those that came from stubby) are eligible
    -- Stubs have modules = {'gencode'} and no inputs/outputs in data table
    -- But we check the original api config, not the mkapi result
    for _, inp in ipairs(apicfg.inputs or {}) do
      if not is_c_eligible_type(inp.type) then
        return false
      end
    end
    for _, out in ipairs(apicfg.outputs or {}) do
      if not is_c_eligible_output(out) then
        return false
      end
    end
    return true
  end

  local c_enums_used = {}
  local c_stringenums_used = {}

  local function collect_types(ty)
    if type(ty) ~= 'table' then
      return
    end
    if ty.enum then
      c_enums_used[ty.enum] = true
    end
    if ty.stringenum then
      c_stringenums_used[ty.stringenum] = true
    end
    if ty.structure then
      local st = structures[ty.structure]
      if st then
        for _, field in pairs(st.fields) do
          collect_types(field.type)
        end
      end
    end
    if ty.arrayof then
      collect_types(ty.arrayof)
    end
  end

  local function safename(name)
    return name:gsub('[%.:]', '_')
  end

  local function cstring(s)
    return '"' .. s:gsub('\\', '\\\\'):gsub('"', '\\"'):gsub('\n', '\\n') .. '"'
  end

  -- Collect all eligible stubs from APIs, uiobjects, and luaobjects
  -- We need the original YAML config (before mkapi) for APIs
  local rawapis = parseYaml('data/products/' .. product .. '/apis.yaml')
  local c_stubs = {} -- {name, apicfg_raw, skip0, kind, parent}
  local c_stub_set = {} -- quick lookup: c_stub_set["APIName"] = true

  for k, v in sorted(rawapis) do
    if not v.impl and is_c_eligible_stub(v) then
      table.insert(c_stubs, { name = k, cfg = v, skip0 = false, kind = 'api' })
      c_stub_set[k] = true
      for _, inp in ipairs(v.inputs or {}) do
        collect_types(inp.type)
      end
      for _, out in ipairs(v.outputs or {}) do
        collect_types(out.type)
      end
    end
  end

  for objname, objcfg in sorted(uiobjectdata) do
    for mname, mv in sorted(objcfg.methods) do
      if not mv.impl and is_c_eligible_stub(mv) then
        local fullname = objname .. ':' .. mname
        table.insert(c_stubs, { name = fullname, cfg = mv, skip0 = true, kind = 'uiobject', parent = objname })
        c_stub_set[fullname] = true
        for _, inp in ipairs(mv.inputs or {}) do
          collect_types(inp.type)
        end
        for _, out in ipairs(mv.outputs or {}) do
          collect_types(out.type)
        end
      end
    end
  end

  do
    local luaobjectdata = parseYaml('data/products/' .. product .. '/luaobjects.yaml')
    for objname, v in sorted(luaobjectdata) do
      if not v.impl then
        for mname, mv in sorted(v.methods or {}) do
          if is_c_eligible_stub(mv) then
            local fullname = objname .. ':' .. mname
            table.insert(c_stubs, { name = fullname, cfg = mv, skip0 = true, kind = 'luaobject', parent = objname })
            c_stub_set[fullname] = true
            for _, inp in ipairs(mv.inputs or {}) do
              collect_types(inp.type)
            end
            for _, out in ipairs(mv.outputs or {}) do
              collect_types(out.type)
            end
          end
        end
      end
    end
  end

  -- Mark eligible stubs in the data table
  for k in pairs(c_stub_set) do
    if apis[k] then
      apis[k].cstub = true
    end
  end
  for objname, obj in pairs(uiobjects) do
    for mname in pairs(obj.methods) do
      if c_stub_set[objname .. ':' .. mname] then
        obj.methods[mname].cstub = true
      end
    end
  end
  for objname, obj in pairs(luaobjects) do
    for mname in pairs(obj.methods) do
      if c_stub_set[objname .. ':' .. mname] then
        obj.methods[mname].cstub = true
      end
    end
  end

  -- Now generate the C file
  local out = {}
  local function emit(...)
    table.insert(out, string.format(...))
  end
  local function emitraw(s)
    table.insert(out, s)
  end

  -- Helper: generate C error return for type mismatch
  -- Produces: return luaL_error(L, "input \"name\" is of type \"tname\", but \"actual\" was passed", ...);
  local function cerror_mismatch(indent, name, tname, stack_idx_expr)
    if name and name ~= '' then
      return indent
        .. 'return luaL_error(L, "input \\"%s\\" is of type \\"%s\\", but \\"%s\\" was passed", '
        .. cstring(name)
        .. ', '
        .. cstring(tname)
        .. ', luaL_typename(L, '
        .. stack_idx_expr
        .. '));'
    else
      return indent
        .. 'return luaL_error(L, "input is of type \\"%s\\", but \\"%s\\" was passed", '
        .. cstring(tname)
        .. ', luaL_typename(L, '
        .. stack_idx_expr
        .. '));'
    end
  end

  -- Helper: generate C error return for nil
  local function cerror_nil(indent, name)
    if name and name ~= '' then
      return indent
        .. 'return luaL_error(L, "input \\"%s\\" is not nilable, but nil was passed", '
        .. cstring(name)
        .. ');'
    else
      return indent .. 'return luaL_error(L, "input is not nilable, but nil was passed");'
    end
  end

  -- Helper: generate C error return for stringenum value
  local function cerror_stringenum(indent, name, ename)
    if name and name ~= '' then
      return indent
        .. 'return luaL_error(L, "input \\"%s\\" is of type \\"%s\\", which does not have value \\"%s\\"", '
        .. cstring(name)
        .. ', '
        .. cstring(ename)
        .. ', s);'
    else
      return indent
        .. 'return luaL_error(L, "input is of type \\"%s\\", which does not have value \\"%s\\"", '
        .. cstring(ename)
        .. ', s);'
    end
  end

  emitraw('#include "lua.h"')
  emitraw('#include "lauxlib.h"')
  emitraw('#include <string.h>')
  emitraw('#include <ctype.h>')
  emitraw('')
  emitraw('static int stub_noop(lua_State *L) { (void)L; return 0; }')
  emitraw('')

  -- Emit enum value tables
  for ename in sorted(c_enums_used) do
    local evalues = globals.Enum[ename]
    if evalues then
      local vals = {}
      for _, v in sorted(evalues) do
        table.insert(vals, v)
      end
      table.sort(vals)
      emit('static const lua_Number enum_%s[] = {', safename(ename))
      for i, v in ipairs(vals) do
        emit('  %s%s', tostring(v), i < #vals and ',' or '')
      end
      emitraw('};')
      emit('#define enum_%s_n %d', safename(ename), #vals)
      emitraw('')
    end
  end

  -- Emit stringenum value tables
  for sname in sorted(c_stringenums_used) do
    local svalues = stringenums[sname]
    if svalues then
      local vals = {}
      for k in sorted(svalues) do
        table.insert(vals, k)
      end
      emit('static const char *const stringenum_%s[] = {', safename(sname))
      for i, v in ipairs(vals) do
        emit('  %s%s', cstring(v), i < #vals and ',' or '')
      end
      emitraw('};')
      emit('#define stringenum_%s_n %d', safename(sname), #vals)
      emitraw('')
    end
  end

  -- Helper: emit C code to push an arbitrary Lua value (scalar or table)
  local function emit_push_value(v, indent)
    if type(v) == 'boolean' then
      emit('%slua_pushboolean(L, %d);', indent, v and 1 or 0)
    elseif type(v) == 'number' then
      emit('%slua_pushnumber(L, %s);', indent, tostring(v))
    elseif type(v) == 'string' then
      emit('%slua_pushliteral(L, %s);', indent, cstring(v))
    elseif type(v) == 'table' then
      emit('%slua_newtable(L);', indent)
      -- Check if it's an array (sequential integer keys) or a dict
      local is_array = #v > 0
      if is_array then
        for i, elem in ipairs(v) do
          emit_push_value(elem, indent .. '  ')
          emit('%s  lua_rawseti(L, -2, %d);', indent, i)
        end
      end
      for k, val in sorted(v) do
        -- Skip integer keys already handled by ipairs
        if not is_array or type(k) ~= 'number' then
          emit_push_value(val, indent .. '  ')
          if type(k) == 'string' then
            emit('%s  lua_setfield(L, -2, %s);', indent, cstring(k))
          elseif type(k) == 'number' and not is_array then
            emit('%s  lua_rawseti(L, -2, %d);', indent, k)
          end
        end
      end
    end
  end

  -- Helper: emit C code for a structure default
  local function emit_structure_default(sname, indent)
    local st = assert(structures[sname], sname)
    emit('%slua_newtable(L);', indent)
    for fname, field in sorted(st.fields) do
      local function push_default(spec, ind)
        if spec.stub ~= nil then
          emit_push_value(spec.stub, ind)
          return true
        end
        if spec.default ~= nil then
          emit_push_value(spec.default, ind)
          return true
        end
        if spec.nilable then
          return false -- nil, skip field
        end
        local ty = spec.type
        if ty == 'boolean' or ty == false then
          emit('%slua_pushboolean(L, 0);', ind)
        elseif ty == 'number' then
          emit('%slua_pushnumber(L, 1);', ind)
        elseif ty == 'string' then
          emit('%slua_pushliteral(L, "");', ind)
        elseif ty == 'FileAsset' then
          emit('%slua_pushnumber(L, 1);', ind)
        elseif ty == 'table' then
          emit('%slua_newtable(L);', ind)
        elseif ty == 'function' then
          emit('%slua_pushcfunction(L, stub_noop);', ind)
        elseif type(ty) == 'table' and ty.enum then
          local meta = globals.Enum[ty.enum .. 'Meta']
          emit('%slua_pushnumber(L, %s);', ind, tostring(meta.MinValue))
        elseif type(ty) == 'table' and ty.stringenum then
          local least
          for k in pairs(stringenums[ty.stringenum]) do
            least = (least == nil or k < least) and k or least
          end
          emit('%slua_pushliteral(L, %s);', ind, cstring(least))
        elseif type(ty) == 'table' and ty.structure then
          emit_structure_default(ty.structure, ind)
        elseif type(ty) == 'table' and ty.arrayof then
          emit('%slua_newtable(L);', ind)
          -- single element array
          push_default({ type = ty.arrayof }, ind)
          emit('%slua_rawseti(L, -2, 1);', ind)
        else
          emit('%slua_pushnil(L);', ind)
        end
        return true
      end
      if push_default(field, indent .. '  ') then
        emit('%s  lua_setfield(L, -2, %s);', indent, cstring(fname))
      end
    end
  end

  -- Helper: emit C code to push a stub output value
  local function emit_push_output(spec, indent)
    if spec.stub ~= nil then
      emit_push_value(spec.stub, indent)
      return
    end
    if spec.default ~= nil then
      emit_push_value(spec.default, indent)
      return
    end
    if spec.nilable and not spec.stubnotnil then
      emit('%slua_pushnil(L);', indent)
      return
    end
    local ty = spec.type
    if ty == 'boolean' or ty == false then
      emit('%slua_pushboolean(L, 0);', indent)
    elseif ty == 'number' then
      emit('%slua_pushnumber(L, 1);', indent)
    elseif ty == 'string' then
      emit('%slua_pushliteral(L, "");', indent)
    elseif ty == 'FileAsset' then
      emit('%slua_pushnumber(L, 1);', indent)
    elseif ty == 'table' then
      emit('%slua_newtable(L);', indent)
    elseif ty == 'function' then
      emit('%slua_pushcfunction(L, stub_noop);', indent)
    elseif ty == 'nil' or ty == 'oneornil' or ty == 'unknown' then
      emit('%slua_pushnil(L);', indent)
    elseif type(ty) == 'table' and ty.enum then
      local meta = globals.Enum[ty.enum .. 'Meta']
      emit('%slua_pushnumber(L, %s);', indent, tostring(meta.MinValue))
    elseif type(ty) == 'table' and ty.stringenum then
      local least
      for k in pairs(stringenums[ty.stringenum]) do
        least = (least == nil or k < least) and k or least
      end
      emit('%slua_pushliteral(L, %s);', indent, cstring(least))
    elseif type(ty) == 'table' and ty.structure then
      emit_structure_default(ty.structure, indent)
    elseif type(ty) == 'table' and ty.arrayof then
      emit('%slua_newtable(L);', indent)
      emit_push_output({ type = ty.arrayof }, indent)
      emit('%slua_rawseti(L, -2, 1);', indent)
    else
      emit('%slua_pushnil(L);', indent)
    end
  end

  -- Helper: emit typestr for error messages (matches typecheck.lua typestr)
  local function typestr(ty)
    if type(ty) == 'string' then
      return ty
    end
    if ty.uiobject then
      return ty.uiobject
    end
    if ty.stringenum then
      return ty.stringenum
    end
    if ty.structure then
      return ty.structure
    end
    if ty.arrayof then
      return typestr(ty.arrayof) .. ' array'
    end
    if ty.enum then
      return ty.enum
    end
    return 'unknown'
  end

  -- Helper: emit input typecheck for a single argument
  local function emit_input_check(spec, stack_idx)
    local ind = '  '
    local name = spec.name
    local is_nilable = spec.nilable or nilables[spec.type]
    local has_default = spec.default ~= nil
    local sidx = tostring(stack_idx)
    local ty = spec.type
    local tname = typestr(ty)

    -- Non-nilable number: luaL_checknumber handles nil + type check
    if ty == 'number' and not is_nilable and not has_default then
      emit('%sluaL_checknumber(L, %d);', ind, stack_idx)
      return
    end

    -- Non-nilable string: luaL_checkstring handles nil + type check (coerces numbers)
    if ty == 'string' and not is_nilable and not has_default then
      emit('%sluaL_checkstring(L, %d);', ind, stack_idx)
      return
    end

    -- Non-nilable enum: luaL_checknumber + membership check
    if type(ty) == 'table' and ty.enum and not is_nilable and not has_default then
      if ty.enum:sub(-4) ~= 'Flag' then
        emit('%s{', ind)
        emit('%s  lua_Number v = luaL_checknumber(L, %d);', ind, stack_idx)
        emit('%s  int found = 0;', ind)
        emit('%s  int i;', ind)
        emit('%s  for (i = 0; i < enum_%s_n; i++) {', ind, safename(ty.enum))
        emit('%s    if (enum_%s[i] == v) { found = 1; break; }', ind, safename(ty.enum))
        emit('%s  }', ind)
        emit('%s  (void)found; /* enum membership is a warning, not an error */', ind)
        emit('%s}', ind)
      else
        emit('%sluaL_checknumber(L, %d);', ind, stack_idx)
      end
      return
    end

    if is_nilable or has_default then
      emit('%sif (!lua_isnoneornil(L, %d)) {', ind, stack_idx)
      ind = '    '
    else
      emit('%sif (lua_isnoneornil(L, %d)) {', ind, stack_idx)
      emitraw(cerror_nil(ind .. '  ', name))
      emit('%s}', ind)
    end

    if ty == 'number' then
      emit('%sif (!lua_isnumber(L, %d)) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'number', sidx))
      emit('%s}', ind)
    elseif ty == 'string' then
      emit('%sif (lua_type(L, %d) != LUA_TSTRING && lua_type(L, %d) != LUA_TNUMBER) {', ind, stack_idx, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'string', sidx))
      emit('%s}', ind)
    elseif ty == 'FileAsset' then
      emit('%sif (lua_type(L, %d) != LUA_TNUMBER && lua_type(L, %d) != LUA_TSTRING) {', ind, stack_idx, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'FileAsset', sidx))
      emit('%s}', ind)
    elseif ty == 'function' then
      emit('%sif (lua_type(L, %d) != LUA_TFUNCTION) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'function', sidx))
      emit('%s}', ind)
    elseif ty == 'table' then
      emit('%sif (lua_type(L, %d) != LUA_TTABLE) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'table', sidx))
      emit('%s}', ind)
    elseif ty == 'userdata' then
      emit('%sif (lua_type(L, %d) != LUA_TUSERDATA) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'userdata', sidx))
      emit('%s}', ind)
    elseif ty == 'oneornil' then
      emit('%sif (lua_type(L, %d) != LUA_TNUMBER || lua_tonumber(L, %d) != 1) {', ind, stack_idx, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, 'oneornil', sidx))
      emit('%s}', ind)
    elseif ty == 'nil' then
      -- always nil, but we're in the non-nil branch - error
      emitraw(cerror_mismatch(ind, name, 'nil', sidx))
    elseif type(ty) == 'table' and ty.enum then
      emit('%s{', ind)
      emit('%s  lua_Number v;', ind)
      emit('%s  if (!lua_isnumber(L, %d)) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '    ', name, tname, sidx))
      emit('%s  }', ind)
      emit('%s  v = lua_tonumber(L, %d);', ind, stack_idx)
      if ty.enum:sub(-4) ~= 'Flag' then
        emit('%s  {', ind)
        emit('%s    int found = 0;', ind)
        emit('%s    int i;', ind)
        emit('%s    for (i = 0; i < enum_%s_n; i++) {', ind, safename(ty.enum))
        emit('%s      if (enum_%s[i] == v) { found = 1; break; }', ind, safename(ty.enum))
        emit('%s    }', ind)
        emit('%s    (void)found; /* enum membership is a warning, not an error */', ind)
        emit('%s  }', ind)
      end
      emit('%s}', ind)
    elseif type(ty) == 'table' and ty.stringenum then
      emit('%sif (lua_type(L, %d) != LUA_TSTRING) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, tname, sidx))
      emit('%s} else {', ind)
      emit('%s  const char *s = lua_tostring(L, %d);', ind, stack_idx)
      emit('%s  int found = 0;', ind)
      emit('%s  int i;', ind)
      emit('%s  char upper[256];', ind)
      emit('%s  size_t len = strlen(s);', ind)
      emit('%s  size_t j;', ind)
      emit('%s  if (len >= sizeof(upper)) len = sizeof(upper) - 1;', ind)
      emit('%s  for (j = 0; j < len; j++) upper[j] = (char)toupper((unsigned char)s[j]);', ind)
      emit('%s  upper[len] = 0;', ind)
      emit('%s  for (i = 0; i < stringenum_%s_n; i++) {', ind, safename(ty.stringenum))
      emit('%s    if (strcmp(stringenum_%s[i], upper) == 0) { found = 1; break; }', ind, safename(ty.stringenum))
      emit('%s  }', ind)
      emit('%s  if (!found) {', ind)
      emitraw(cerror_stringenum(ind .. '    ', name, ty.stringenum))
      emit('%s  }', ind)
      emit('%s}', ind)
    elseif type(ty) == 'table' and ty.structure then
      emit('%sif (lua_type(L, %d) != LUA_TTABLE) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, tname, sidx))
      emit('%s}', ind)
    elseif type(ty) == 'table' and ty.arrayof then
      emit('%sif (lua_type(L, %d) != LUA_TTABLE) {', ind, stack_idx)
      emitraw(cerror_mismatch(ind .. '  ', name, tname, sidx))
      emit('%s}', ind)
    end

    if is_nilable or has_default then
      emitraw('  }')
    end
  end

  -- Generate each stub function
  for _, stub in ipairs(c_stubs) do
    local sn = safename(stub.name)
    emit('static int stub_%s(lua_State *L) {', sn)

    local cfg = stub.cfg
    local ins = cfg.inputs or {}
    local outs = cfg.outputs or {}
    local instride = cfg.instride or 0
    local nsins = #ins - instride
    local stack_offset = stub.skip0 and 1 or 0

    -- Check fixed inputs
    for i = 1, nsins do
      emit('  /* input %d: %s */', i, ins[i].name or tostring(ins[i].type))
      emit_input_check(ins[i], i + stack_offset)
    end

    -- Check variadic inputs (instride)
    if instride > 0 then
      emit('  {')
      emit('    int top = lua_gettop(L);')
      emit('    int i;')
      emit('    for (i = %d; i <= top; i += %d) {', nsins + 1 + stack_offset, instride)
      for j = 1, instride do
        local spec = ins[nsins + j]
        emit('      /* stride arg %d: %s */', j, spec.name or tostring(spec.type))
        -- For variadic args, stack index is i + (j-1)
        -- We use a simplified check here
        emit('      {')
        emit('        int idx = i + %d;', j - 1)
        emit('        if (idx <= top) {')
        local vname = spec.name
        local is_nilable_v = spec.nilable or nilables[spec.type]
        local vty = spec.type
        -- Non-nilable number/string: luaL_check* handles nil + type
        if vty == 'number' and not is_nilable_v then
          emitraw('          luaL_checknumber(L, idx);')
        elseif vty == 'string' and not is_nilable_v then
          emitraw('          luaL_checkstring(L, idx);')
        else
          if is_nilable_v then
            emitraw('          if (!lua_isnoneornil(L, idx)) {')
          else
            emitraw('          if (lua_isnoneornil(L, idx)) {')
            emitraw(cerror_nil('            ', vname))
            emitraw('          } else {')
          end
          if vty == 'number' then
            emitraw('            if (!lua_isnumber(L, idx)) {')
            emitraw(cerror_mismatch('              ', vname, 'number', 'idx'))
            emitraw('            }')
          elseif vty == 'string' then
            emitraw('            if (lua_type(L, idx) != LUA_TSTRING && lua_type(L, idx) != LUA_TNUMBER) {')
            emitraw(cerror_mismatch('              ', vname, 'string', 'idx'))
            emitraw('            }')
          elseif vty ~= 'boolean' and vty ~= 'any' and vty ~= 'unknown' and vty ~= 'gender' and vty ~= 'tostring' then
            emitraw('            (void)idx;')
          end
          emitraw('          }')
        end
        emit('        }')
        emit('      }')
      end
      emit('    }')
      emit('  }')
    end

    -- Push outputs
    if #outs > 0 and not cfg.stubnothing then
      local nonstride = #outs - (cfg.outstride or 0)
      local nrets = 0
      for i = 1, nonstride do
        emit_push_output(outs[i], '  ')
        nrets = nrets + 1
      end
      for _ = 1, cfg.stuboutstrides or 1 do
        for j = nonstride + 1, #outs do
          emit_push_output(outs[j], '  ')
          nrets = nrets + 1
        end
      end
      emit('  return %d;', nrets)
    else
      emit('  return 0;')
    end

    emitraw('}')
    emitraw('')
  end

  -- Emit luaopen registration function
  local modname = 'build_products_' .. product .. '_stubs'
  emit('int luaopen_%s(lua_State *L) {', modname)
  emitraw('  lua_newtable(L);')
  for _, stub in ipairs(c_stubs) do
    local sn = safename(stub.name)
    emit('  lua_pushcfunction(L, stub_%s);', sn)
    -- Use dot-separated name for APIs, colon-separated for methods
    emit('  lua_setfield(L, -2, %s);', cstring(stub.name))
  end
  emitraw('  return 1;')
  emitraw('}')

  require('pl.file').write(args.coutput, table.concat(out, '\n') .. '\n')
  tu.writedeps(args.coutput, deps)
end

tu.writedeps(outfn, deps)
require('pl.file').write(outfn, tu.returntable(data))
