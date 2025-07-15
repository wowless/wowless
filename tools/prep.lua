local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  parser:option('-o --output', 'output file')
  parser:option('-s --stamp', 'stamp file')
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
    Font = 'api.CreateUIObject("font").luarep',
    FontString = 'api.CreateUIObject("fontstring").luarep',
    ['function'] = 'function() end',
    MaskTexture = 'api.CreateUIObject("masktexture").luarep',
    ['nil'] = 'nil',
    number = '1',
    oneornil = 'nil',
    Region = 'nil',
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
      for fname, field in require('pl.tablex').sort(st.fields) do
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
    if stringenums[ty] then
      local least
      for k in pairs(stringenums[ty]) do
        least = (least == nil or k < least) and k or least
      end
      return least
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
    error('unexpected type: ' .. require('pl.pretty').write(ty))
  end
  return specDefault
end)()

local apis = {}
local impls = {}
local sqls = {}
do
  local cfg = parseYaml('data/products/' .. product .. '/apis.yaml')
  local implcfg = parseYaml('data/impl.yaml')
  local sqlcfg = parseYaml('data/sql.yaml')
  for name, apicfg in pairs(cfg) do
    if apicfg.impl then
      local ic = assert(implcfg[apicfg.impl], 'missing impl ' .. apicfg.impl)
      if ic.stdlib then
        apicfg.impl = nil
        apicfg.stdlib = ic.stdlib
      end
      for _, v in ipairs(ic.sqls or { ic.directsql }) do
        if not sqls[v] then
          local sql = sqlcfg[v]
          sqls[v] = {
            sql = readFile('data/sql/' .. v .. '.sql'),
            table = sql.table,
            type = sql.type,
          }
        end
      end
      if not impls[apicfg.impl] then
        if ic.module then
          local fmt = 'return (...).modules[%q][%q]'
          impls[apicfg.impl] = {
            frameworks = { 'api' },
            src = fmt:format(ic.module, ic['function'] or apicfg.impl),
          }
        elseif ic.delegate then
          impls[apicfg.impl] = {
            src = 'return ' .. ic.delegate,
          }
        elseif ic.directsql then
          impls[apicfg.impl] = {
            sqls = { ic.directsql },
            src = 'return (...)',
          }
        elseif not ic.stdlib then
          impls[apicfg.impl] = {
            frameworks = ic.frameworks,
            sqls = ic.sqls,
            src = readFile('data/impl/' .. apicfg.impl .. '.lua'),
          }
        end
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
  cvars[k:lower()] = {
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
-- Getters can manipulate inherited fields, so we need that info.
local uiobjectfieldsets = {}
local function mkuiobjectfieldset(k)
  local set = uiobjectfieldsets[k]
  if not set then
    set = {}
    local v = uiobjectdata[k]
    for inh in pairs(v.inherits) do
      Mixin(set, mkuiobjectfieldset(inh))
    end
    for fk, fv in pairs(v.fields) do
      set[fk] = fv
    end
    uiobjectfieldsets[k] = set
  end
  return set
end
local uiobjects = {}
for k, v in pairs(uiobjectdata) do
  local constructor = { 'local hlist=...;return function()return{' }
  for fk, fv in require('pl.tablex').sort(mkuiobjectinit(k)) do
    table.insert(constructor, ('%s=%s,'):format(fk, fv))
  end
  table.insert(constructor, '}end')
  local fieldset = mkuiobjectfieldset(k)
  local methods = {}
  for mk, mv in pairs(v.methods) do
    if type(mv.impl) == 'string' then
      assert(uiobjectimpl[mv.impl])
      local src = 'data/uiobjects/' .. mv.impl .. '.lua'
      methods[mk] = {
        impl = readFile(src),
        inputs = mv.inputs,
        mayreturnnothing = mv.mayreturnnothing,
        outputs = mv.outputs,
        outstride = mv.outstride,
        src = src,
      }
    elseif mv.impl and mv.impl.getter then
      local t = { 'local _,_,check=...;' }
      for i, f in ipairs(mv.impl.getter) do
        local cf = fieldset[f.name]
        table.insert(t, 'local spec' .. i .. '=')
        local output = { -- issue #421
          nilable = cf.nilable,
          type = cf.type,
        }
        table.insert(t, plprettywrite(output, '') .. ';')
      end
      table.insert(t, 'return function(self)return ')
      for i, f in ipairs(mv.impl.getter) do
        table.insert(t, (i == 1 and '' or ',') .. 'check(spec' .. i .. ',self.' .. f.name .. ',true)')
      end
      table.insert(t, 'end')
      methods[mk] = table.concat(t)
    elseif mv.impl and mv.impl.setter then
      local t = { 'local api,toTexture,check,Mixin=...;' }
      for i, f in ipairs(mv.impl.setter) do
        local cf = fieldset[f.name]
        if cf.type ~= 'Texture' then
          table.insert(t, 'local spec' .. i .. '=')
          local input = mv.inputs and mv.inputs[i]
            or { -- issue #416
              nilable = cf.type == 'boolean' or cf.nilable or nil,
              type = cf.type,
            }
          table.insert(t, plprettywrite(input, '') .. ';')
        end
      end
      table.insert(t, 'return function(self')
      for _, f in ipairs(mv.impl.setter) do
        table.insert(t, ',')
        table.insert(t, f.name)
      end
      table.insert(t, ')')
      for i, f in ipairs(mv.impl.setter) do
        local cf = fieldset[f.name]
        table.insert(t, 'self.')
        table.insert(t, f.name)
        table.insert(t, '=')
        if cf.type == 'Texture' then
          table.insert(t, 'toTexture(self,' .. f.name .. ',self.')
        else
          table.insert(t, 'check(spec')
          table.insert(t, tostring(i))
          table.insert(t, ',')
        end
        table.insert(t, f.name)
        table.insert(t, ');')
      end
      table.insert(t, 'end')
      methods[mk] = table.concat(t)
    else
      local t = { 'local api,toTexture,check,Mixin=...;' }
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
      methods[mk] = table.concat(t)
    end
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
tu.writedeps(outfn, deps, args.stamp)
tu.writeifchanged(outfn, tu.returntable(data))
