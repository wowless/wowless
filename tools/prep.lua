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

local getStub = (function()
  local structures = parseYaml('data/products/' .. product .. '/structures.yaml')
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
  local function ensureStructureDefault(name)
    if structureDefaults[name] == nil then
      structureDefaults[name] = true
      local st = assert(structures[name], name)
      local t = {}
      for fname, field in require('pl.tablex').sort(st) do
        local v
        if structures[field.type.structure] then
          ensureStructureDefault(field.type.structure)
          v = structureDefaults[field.type.structure]
          if field.type.mixin then
            v = ('Mixin(%s,%s)'):format(v, field.type.mixin)
          end
        elseif field.type.arrayof then
          if defaultOutputs[field.type.arrayof] then
            v = '{}'
          else
            ensureStructureDefault(field.type.arrayof)
            v = '{' .. structureDefaults[field.type.arrayof] .. '}'
          end
        elseif field.stub then
          assert(type(field.stub) == 'string', 'only string stubs supported in structures')
          v = string.format('%q', field.stub)
        else
          v = tostring(defaultOutputs[field.nilable and 'nil' or field.type])
        end
        if v ~= 'nil' then
          table.insert(t, ('[%q]=%s'):format(fname, v))
        end
      end
      structureDefaults[name] = '{' .. table.concat(t, ',') .. '}'
    else
      assert(structureDefaults[name] ~= true, 'loop in structure definitions')
    end
  end
  for name in pairs(structures) do
    ensureStructureDefault(name)
  end
  return function(sig)
    local rets = {}
    for _, out in ipairs(sig) do
      local v
      if out.stub or out.default then
        local value = out.stub or out.default
        local ty = type(value)
        if ty == 'number' or ty == 'boolean' then
          v = tostring(value)
        elseif ty == 'string' then
          v = string.format('%q', value)
        elseif ty == 'table' then
          v = plprettywrite(value)
        else
          error('unsupported stub value type ' .. ty)
        end
      elseif out.nilable then
        v = 'nil'
      else
        v = defaultOutputs[out.type] or structureDefaults[out.type]
      end
      assert(v, ('invalid output type %q'):format(out.type))
      table.insert(rets, v)
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
    neverSent = v.payload == nil or nil,
    payload = v.payload or {},
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
