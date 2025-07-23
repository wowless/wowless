local wdata = require('wowapi.data')
local domains = {
  family = wdata.families,
  gametype = wdata.gametypes,
  impl = wdata.impl,
  schema = wdata.schemas,
  sql = wdata.sql,
  stringenum = wdata.stringenums,
  uiobjectimpl = wdata.uiobjectimpl,
}
local productDomains = {
  api = wdata.apis,
  cvar = wdata.cvars,
  enum = wdata.enums,
  event = wdata.events,
  structure = wdata.structures,
  uiobject = wdata.uiobjects,
  xml = wdata.xml,
}

local validators = {
  boolean = function(v)
    assert(type(v) == 'boolean', 'expected boolean')
  end,
  number = function(v)
    assert(type(v) == 'number', 'expected number')
  end,
  string = function(v)
    assert(type(v) == 'string', 'expected string')
  end,
  table = function(v)
    assert(type(v) == 'table', 'expected table')
  end,
}

local pretty = require('pl.pretty').write

local compile

local function docompile(schematype)
  if type(schematype) ~= 'table' then
    error('unexpected schema type ' .. pretty(schematype))
  elseif schematype.schema then
    local schema = wdata.schemas[schematype.schema]
    if not schema then
      error('bad schema: ' .. schematype.schema)
    end
    local cached
    return function(v, product)
      if not cached then
        -- We have to handle schema refs lazily to support circular refs.
        cached = compile(schema.type)
      end
      return cached(v, product)
    end
  elseif schematype.record then
    local fields = {}
    local required = {}
    for k, v in pairs(schematype.record) do
      fields[k] = compile(v.type)
      required[k] = v.required or nil
    end
    return function(v, product)
      assert(type(v) == 'table', 'expected table')
      for vk, vv in pairs(v) do
        local field = fields[vk]
        if not field then
          error('unknown field ' .. vk)
        end
        field(vv, product)
      end
      for k in pairs(required) do
        if v[k] == nil then
          error('missing required field ' .. k)
        end
      end
    end
  elseif schematype.mapof then
    local key = compile(schematype.mapof.key)
    local value = compile(schematype.mapof.value)
    return function(v, product)
      assert(type(v) == 'table', 'expected table')
      for vk, vv in pairs(v) do
        key(vk, product)
        value(vv, product)
      end
    end
  elseif schematype.sequenceof then
    local element = compile(schematype.sequenceof)
    return function(v, product)
      assert(type(v) == 'table', 'expected table')
      local max = 0
      for vk, vv in pairs(v) do
        assert(type(vk) == 'number', 'expected number key')
        max = vk > max and vk or max
        element(vv, product)
      end
      assert(max == #v, 'expected array')
    end
  elseif schematype.oneof then
    local oneof = {}
    for i, v in ipairs(schematype.oneof) do
      oneof[i] = compile(v)
    end
    return function(v, product)
      local errors = {}
      for _, element in ipairs(oneof) do
        local success, err = pcall(element, v, product)
        if success then
          return
        else
          table.insert(errors, err)
        end
      end
      error('did not validate against any element of oneof: ' .. pretty(errors))
    end
  elseif schematype.literal then
    local s = schematype.literal
    return function(v)
      assert(type(v) == 'string', 'expected string')
      assert(v == s, 'string literal mismatch')
    end
  elseif schematype.ref then
    local ref = schematype.ref
    local gdomain = domains[ref]
    local pdomains = productDomains[ref]
    return function(v, product)
      assert(type(v) == 'string', 'expected string in ref')
      local domain = gdomain or pdomains and pdomains[product]
      assert(domain, 'bad schema: invalid domain')
      if not domain[v] then
        error('unknown domain value ' .. v)
      end
    end
  else
    error('expected record/mapof/sequenceof/oneof')
  end
end

function compile(schematype)
  local key = type(schematype) == 'string' and schematype or pretty(schematype, '')
  local validator = validators[key]
  if not validator then
    validator = docompile(schematype)
    validators[key] = validator
  end
  return validator
end

local function validate(product, schematype, v)
  return compile(schematype)(v, product)
end

return {
  validate = validate,
}
