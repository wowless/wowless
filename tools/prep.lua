local args = (function()
  local parser = require('argparse')()
  parser:argument('product', 'product to fetch')
  return parser:parse()
end)()

local product = args.product
local function parseYaml(...)
  return (assert(require('wowapi.yaml').parseFile(...)))
end
local function readFile(...)
  return (assert(require('pl.file').read(...)))
end
local plprettywrite = require('pl.pretty').write

local specDefault = (function()
  local defaultOutputs = {
    boolean = 'false',
    ['function'] = 'function() end',
    ['nil'] = 'nil',
    number = '1',
    oneornil = 'nil',
    string = '\'\'',
    table = '{}',
    unknown = 'nil',
  }
  local structureDefaults = {}
  local structures = parseYaml('data/products/' .. product .. '/structures.yaml')
  local specDefault
  local function valstruct(name, mixin)
    if not structureDefaults[name] then
      local st = assert(structures[name], name)
      local t = {}
      for fname, field in require('pl.tablex').sort(st) do
        local v = specDefault(field)
        if v ~= 'nil' then
          table.insert(t, ('[%q]=%s'):format(fname, v))
        end
      end
      structureDefaults[name] = '{' .. table.concat(t, ',') .. '}'
    end
    local v = structureDefaults[name]
    return mixin and ('Mixin(%s,%s)'):format(v, mixin) or v
  end
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
    if ty.arrayof then
      return '{' .. specDefault({ type = ty.arrayof }) .. '}'
    end
    if ty.structure then
      return valstruct(ty.structure, ty.mixin)
    end
    -- TODO remove this when api specs are refactored
    if structures[ty] then
      return valstruct(ty, spec.mixin)
    end
    error('unexpected type: ' .. require('pl.pretty').write(ty))
  end
  return specDefault
end)()

local getStub = (function()
  return function(sig)
    local rets = {}
    for _, out in ipairs(sig) do
      table.insert(rets, specDefault(out))
    end
    return 'return ' .. table.concat(rets, ', ')
  end
end)()

local apis = {}
local impls = {}
local sqlcursors = {}
local sqllookups = {}
do
  local cfg = parseYaml('data/products/' .. product .. '/apis.yaml')
  local implcfg = parseYaml('data/impl.yaml')
  for name, apicfg in pairs(cfg) do
    if not apicfg.debug then
      if apicfg.impl then
        local ic = implcfg[apicfg.impl]
        apicfg.frameworks = ic.frameworks
        apicfg.sqls = ic.sqls
        apicfg.states = ic.states
        if not impls[apicfg.impl] then
          impls[apicfg.impl] = readFile('data/impl/' .. apicfg.impl .. '.lua')
        end
      else
        apicfg.stub = getStub(apicfg.outputs or {})
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

local state = {}
for _, f in ipairs(require('pl.dir').getfiles('data/state')) do
  local cfg = parseYaml(f)
  state[cfg.name] = cfg.value
end

local structures = {}
for k in pairs(parseYaml('data/products/' .. product .. '/structures.yaml')) do
  structures[k] = true
end

local uiobjects = {}
for k, v in pairs(parseYaml('data/products/' .. product .. '/uiobjects.yaml')) do
  local methods = {}
  for mk, mv in pairs(v.methods or {}) do
    if mv.status == 'implemented' then
      mv.impl = readFile('data/uiobjects/' .. k .. '/' .. mk .. '.lua')
    end
    methods[mk] = mv
  end
  v.methods = methods
  uiobjects[k] = v
end

local data = {
  apis = apis,
  build = parseYaml('data/products/' .. product .. '/build.yaml'),
  config = parseYaml('data/products/' .. product .. '/config.yaml'),
  cvars = cvars,
  events = events,
  globals = parseYaml('data/products/' .. product .. '/globals.yaml'),
  impls = impls,
  sqlcursors = sqlcursors,
  sqllookups = sqllookups,
  state = state,
  structures = structures,
  uiobjects = uiobjects,
  xml = parseYaml('data/products/' .. product .. '/xml.yaml'),
}
local txt = 'return ' .. plprettywrite(data)
assert(require('pl.file').write('build/products/' .. args.product .. '/data.lua', txt))
