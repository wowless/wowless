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

local function checkty(ty, v)
  local vty = type(v)
  if vty ~= ty then
    return ('want %s, got %s'):format(ty, vty)
  end
end

local validators = {
  boolean = function(v)
    return checkty('boolean', v)
  end,
  number = function(v)
    return checkty('number', v)
  end,
  string = function(v)
    return checkty('string', v)
  end,
  table = function(v)
    return checkty('table', v)
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
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      for vk, vv in pairs(v) do
        local field = fields[vk]
        errors[vk] = not field and 'unknown field' or field(vv, product)
      end
      for k in pairs(required) do
        if v[k] == nil then
          errors[k] = 'missing required field'
        end
      end
      return next(errors) and errors or nil
    end
  elseif schematype.mapof then
    local key = compile(schematype.mapof.key)
    local value = compile(schematype.mapof.value)
    return function(v, product)
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      for vk, vv in pairs(v) do
        local ek = key(vk, product)
        local ev = value(vv, product)
        if ek or ev then
          errors[vk] = { key = ek, value = ev }
        end
      end
      return next(errors) and errors or nil
    end
  elseif schematype.sequenceof then
    local element = compile(schematype.sequenceof)
    return function(v, product)
      if type(v) ~= 'table' then
        return 'expected table'
      end
      local errors = {}
      local max = 0
      for vk, vv in pairs(v) do
        if type(vk) ~= 'number' then
          errors[vk] = 'expected number'
        else
          max = vk > max and vk or max
          errors[vk] = element(vv, product)
        end
      end
      return max ~= #v and 'expected array' or next(errors) and errors or nil
    end
  elseif schematype.oneof then
    assert(schematype.oneof[1], 'expected nonempty sequence')
    local oneof = {}
    for i, v in ipairs(schematype.oneof) do
      oneof[i] = compile(v)
    end
    return function(v, product)
      local errors = {}
      local n = 0
      for i, element in ipairs(oneof) do
        local err = element(v, product)
        errors[i] = err
        n = n + (err and 0 or 1)
      end
      return n == 0 and errors or n > 1 and 'multiple matches' or nil
    end
  elseif schematype.literal then
    local s = schematype.literal
    return function(v)
      if v ~= s then
        return 'string literal mismatch'
      end
    end
  elseif schematype.ref then
    local ref = schematype.ref
    local gdomain = domains[ref]
    local pdomains = productDomains[ref]
    return function(v, product)
      if type(v) ~= 'string' then
        return 'expected string'
      end
      local domain = gdomain or pdomains and pdomains[product]
      if not domain then
        return 'invalid domain'
      end
      if not domain[v] then
        return 'unknown domain value'
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
  local errors = compile(schematype)(v, product)
  if errors then
    error(errors, 0)
  end
end

return {
  validate = validate,
}
