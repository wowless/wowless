local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:option('--sqls', 'sqls file')
  parser:option('-o --output', 'output file')
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
      structureDefaults[name] = st.mixin and ('Mixin(%s,%q)'):format(str, st.mixin) or str
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
      local e = assert(globals.Enum[ty.enum], 'missing enum ' .. ty.enum)
      -- Unfortunately we cannot rely on the existence of a Meta enum,
      -- so we go fishing for the minimum value manually.
      local x
      for _, v in pairs(e) do
        x = (not x or v < x) and v or x
      end
      return valstr(x)
    end
    if ty.uiobject then
      return ('api.CreateUIObject(%q).luarep'):format(ty.uiobject:lower())
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

local implimpls = {
  delegate = function(impl)
    return {
      src = 'return ' .. impl,
    }
  end,
  directsql = function(impl)
    ensuresql(impl)
    return {
      sqls = { impl },
      src = 'return (...)',
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
    return {
      modules = modules,
      sqls = impl.sqls,
      src = readFile('data/impl/' .. name .. '.lua'),
    }
  end,
  luadelegate = function(impl, name)
    local fmt = 'return require(%q)[%q]'
    return {
      src = fmt:format(impl.module, impl['function'] or name),
    }
  end,
  moduledelegate = function(impl, name)
    return {
      modules = { impl.name },
      src = ('return (...)[%q]'):format(impl['function'] or name),
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
end

local apis = {}
do
  local cfg = parseYaml('data/products/' .. product .. '/apis.yaml')
  for name, apicfg in pairs(cfg) do
    if apicfg.impl then
      local ic = assert(implcfg[apicfg.impl], 'missing impl ' .. apicfg.impl)
      if ic.stdlib then
        apicfg.impl = nil
        apicfg.stdlib = ic.stdlib
      else
        ensureimpl(apicfg.impl)
      end
    elseif apicfg.stubnothing then
      apicfg.stub = ''
    else
      local outs = apicfg.outputs or {}
      local rets = {}
      local nonstride = #outs - (apicfg.outstride or 0)
      for i = 1, nonstride do
        table.insert(rets, specDefault(outs[i]))
      end
      for _ = 1, apicfg.stuboutstrides or 1 do
        for j = nonstride + 1, #outs do
          table.insert(rets, specDefault(outs[j]))
        end
      end
      apicfg.stub = 'return ' .. table.concat(rets, ',')
    end
    apis[name] = apicfg
  end
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
    payload = v.payload,
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
        init[fk] = 'hlist()'
      end
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
    local src = 'data/uiobjects/' .. k .. '.lua'
    return {
      impl = readFile(src),
      modules = modules,
      src = src,
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
    local t = { 'local _,_,check=...;' }
    for i in ipairs(impl) do
      table.insert(t, 'local spec' .. i .. '=' .. plprettywrite(mv.outputs[i], '') .. ';')
    end
    table.insert(t, 'return function(self)return ')
    for i, f in ipairs(impl) do
      table.insert(t, (i == 1 and '' or ',') .. 'check(spec' .. i .. ',self.' .. f.name .. ',true)')
    end
    table.insert(t, 'end')
    return table.concat(t)
  end,
  none = function(mv)
    local t = { 'local api,_,check,Mixin=...;' }
    local ins = mv.inputs or {}
    local nsins = #ins - (mv.instride or 0)
    for i = 1, #ins do
      table.insert(t, 'local spec' .. i .. '=' .. plprettywrite(mv.inputs[i], '') .. ';')
    end
    table.insert(t, 'return function(_')
    for i = 1, nsins do
      table.insert(t, ',arg' .. i)
    end
    if mv.instride then
      table.insert(t, ',...')
    end
    table.insert(t, ')')
    for i = 1, nsins do
      table.insert(t, 'check(spec' .. i .. ',arg' .. i .. ');')
    end
    if mv.instride then
      table.insert(t, 'for i=1,select("#",...),' .. mv.instride .. ' do ')
      table.insert(t, 'local arg' .. nsins + 1)
      for i = nsins + 2, #ins do
        table.insert(t, ',arg' .. i)
      end
      table.insert(t, '=select(i,...);')
      for i = nsins + 1, #ins do
        table.insert(t, 'check(spec' .. i .. ',arg' .. i .. ');')
      end
      table.insert(t, 'end ')
    end
    table.insert(t, 'return ')
    local outs = mv.outputs or {}
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
    table.insert(t, ' end')
    return table.concat(t)
  end,
  setter = function(impl, mv)
    local t = { 'local api,_,check,Mixin=...;' }
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
      table.insert(t, '=check(spec')
      table.insert(t, tostring(i))
      table.insert(t, ',')
      table.insert(t, f.name)
      table.insert(t, ');')
    end
    table.insert(t, 'end')
    return table.concat(t)
  end,
  settexture = function(impl)
    local t = { 'local api,toTexture=...;return function(self,tex)' }
    table.insert(t, 'local t=toTexture(self,tex,self.')
    table.insert(t, impl.field)
    table.insert(t, ');if t then api.SetParent(t,self);if t:GetNumPoints()==0 then t:SetAllPoints()end t:SetShown(')
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
    return table.concat(t)
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
      src = implimpl.src,
    }
  end,
}
local uiobjects = {}
for k, v in pairs(uiobjectdata) do
  local constructor = { 'local hlist=...;return function()return{' }
  for fk, fv in sorted(mkuiobjectinit(k)) do
    table.insert(constructor, ('%s=%s,'):format(fk, fv))
  end
  table.insert(constructor, '}end')
  local methods = {}
  for mk, mv in pairs(v.methods) do
    methods[mk] = dispatch(uiobjectimplmakers, mv.impl or 'none', mv)
  end
  uiobjects[k] = {
    constructor = table.concat(constructor),
    inherits = v.inherits,
    methods = methods,
    objectType = v.objectType,
    singleton = v.singleton,
  }
end

local data = {
  apis = apis,
  build = parseYaml('data/products/' .. product .. '/build.yaml'),
  config = parseYaml('data/products/' .. product .. '/config.yaml'),
  cvars = cvars,
  events = events,
  globals = globals,
  impls = impls,
  product = product,
  sqls = sqls,
  structures = structures,
  uiobjects = uiobjects,
  xml = parseYaml('data/products/' .. product .. '/xml.yaml'),
}

local outfn = args.output or ('build/products/' .. args.product .. '/data.lua')
local tu = require('tools.util')
tu.writedeps(outfn, deps)
require('pl.file').write(outfn, tu.returntable(data))
