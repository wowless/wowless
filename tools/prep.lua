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
    return plprettywrite(value)
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
    if spec.nilable then
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
local sqlcursors = {}
local sqllookups = {}
local states = {
  -- These are unreferenced by any API, alas.
  Bindings = parseYaml('data/state/Bindings.yaml').value,
  ModifiedClicks = parseYaml('data/state/ModifiedClicks.yaml').value,
}
do
  local cfg = parseYaml('data/products/' .. product .. '/apis.yaml')
  local implcfg = parseYaml('data/impl.yaml')
  for name, apicfg in pairs(cfg) do
    if not apicfg.debug then
      if apicfg.impl then
        local ic = assert(implcfg[apicfg.impl], 'missing impl ' .. apicfg.impl)
        apicfg.frameworks = ic.frameworks
        apicfg.sqls = ic.sqls
        apicfg.states = ic.states
        if not impls[apicfg.impl] then
          impls[apicfg.impl] = readFile('data/impl/' .. apicfg.impl .. '.lua')
        end
      elseif apicfg.stubnothing then
        apicfg.stub = ''
      else
        local rets = {}
        for _, out in ipairs(apicfg.outputs or {}) do
          table.insert(rets, specDefault(out))
        end
        apicfg.stub = 'return ' .. table.concat(rets, ',')
      end
      for _, sql in ipairs(apicfg.sqls or {}) do
        if sql.cursor then
          sqlcursors[sql.cursor] = {
            sql = readFile('data/sql/cursor/' .. sql.cursor .. '.sql'),
            table = sql.table,
          }
        elseif sql.lookup then
          sqllookups[sql.lookup] = {
            sql = readFile('data/sql/lookup/' .. sql.lookup .. '.sql'),
            table = sql.table,
          }
        end
      end
      for _, state in ipairs(apicfg.states or {}) do
        if not states[state] then
          local statecfg = parseYaml('data/state/' .. state .. '.yaml')
          states[state] = statecfg.value
        end
      end
      apis[name] = apicfg
    end
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
  events[k] = {
    payload = v.payload and (function()
      local t = {}
      for _, f in ipairs(v.payload or {}) do
        table.insert(t, specDefault(f))
      end
      return 'return ' .. table.concat(t, ',')
    end)(),
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
  local constructor = { 'function() return {' }
  for fk, fv in require('pl.tablex').sort(mkuiobjectinit(k)) do
    table.insert(constructor, ('  %s = %s,'):format(fk, fv))
  end
  table.insert(constructor, '} end')
  local fieldset = mkuiobjectfieldset(k)
  local methods = {}
  for mk, mv in pairs(v.methods) do
    if mv.impl then
      assert(uiobjectimpl[mv.impl])
      methods[mk] = {
        impl = 'function(...) ' .. readFile('data/uiobjects/' .. mv.impl .. '.lua') .. ' end',
        inputs = mv.inputs,
        mayreturnnothing = mv.mayreturnnothing,
        outputs = mv.outputs,
      }
    elseif mv.getter then
      local t = {}
      for _, f in ipairs(mv.getter) do
        if uiobjectdata[fieldset[f.name].type] then
          table.insert(t, 'self.' .. f.name .. ' and self.' .. f.name .. '.luarep')
        else
          table.insert(t, 'self.' .. f.name)
        end
      end
      methods[mk] = 'function(self) return ' .. table.concat(t, ',') .. ' end'
    elseif mv.setter then
      local t = { 'function(self' }
      for _, f in ipairs(mv.setter) do
        table.insert(t, ',')
        table.insert(t, f.name)
      end
      table.insert(t, ') ')
      for _, f in ipairs(mv.setter) do
        local cf = fieldset[f.name]
        table.insert(t, 'self.')
        table.insert(t, f.name)
        table.insert(t, '=')
        if cf.type == 'boolean' then
          table.insert(t, 'not not ')
          table.insert(t, f.name)
        else
          local ct = { 'check.', cf.type, '(', f.name }
          if cf.type == 'Texture' then
            table.insert(ct, ',self')
          end
          table.insert(ct, ')')
          local sct = table.concat(ct, '')
          if f.nilable or cf.nilable then
            table.insert(t, f.name)
            table.insert(t, '~=nil and ')
            table.insert(t, sct)
            table.insert(t, ' or nil')
          else
            table.insert(t, sct)
          end
        end
        table.insert(t, ';')
      end
      table.insert(t, ' end')
      methods[mk] = table.concat(t, '')
    else
      local t = {}
      for _, output in ipairs(mv.outputs or {}) do
        table.insert(t, specDefault(output))
      end
      methods[mk] = 'function() return ' .. table.concat(t, ',') .. ' end'
    end
  end
  uiobjects[k] = {
    constructor = table.concat(constructor, '\n'),
    inherits = v.inherits,
    methods = methods,
    objectType = v.objectType,
    singleton = v.singleton,
    warner = v.warner,
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
  sqlcursors = sqlcursors,
  sqllookups = sqllookups,
  states = states,
  structures = structures,
  uiobjects = uiobjects,
  xml = parseYaml('data/products/' .. product .. '/xml.yaml'),
}

local outfn = args.output or ('build/products/' .. args.product .. '/data.lua')
local tu = require('tools.util')
tu.writedeps(outfn, deps, args.stamp)
tu.writeifchanged(outfn, tu.returntable(data))
