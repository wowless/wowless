local wdata = require('wowapi.data')
local domains = {
  family = wdata.families,
  gametype = wdata.gametypes,
  impl = wdata.impl,
  module = wdata.modules,
  schema = wdata.schemas,
  scripttype = wdata.scripttypes,
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

local function mksimple(ty)
  return function(v)
    local vty = type(v)
    if vty ~= ty then
      return ('want %s, got %s'):format(ty, vty)
    end
  end
end

local simple = {
  any = function() end,
  boolean = mksimple('boolean'),
  number = mksimple('number'),
  string = mksimple('string'),
  table = mksimple('table'),
}

local compile

local schemas = {}

local complex = {
  literal = function(s)
    return function(v)
      if v ~= s then
        return 'string literal mismatch'
      end
    end
  end,
  mapof = function(s)
    local key = compile(s.key)
    local value = compile(s.value)
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
  end,
  record = function(s)
    local fields = {}
    local required = {}
    for k, v in pairs(s) do
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
  end,
  ref = function(s)
    local gdomain = domains[s.schema]
    local pdomains = productDomains[s.schema]
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
  end,
  schema = function(s)
    local schema = wdata.schemas[s]
    if not schema then
      error('bad schema: ' .. s)
    end
    return function(v, product)
      local fn = schemas[s]
      if not fn then
        -- We have to handle schema refs lazily to support circular refs.
        fn = compile(schema.type)
        schemas[s] = fn
      end
      return fn(v, product)
    end
  end,
  sequenceof = function(s)
    local element = compile(s)
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
  end,
  taggedunion = function(s)
    local sf = {}
    local tf = {}
    local ks = {}
    for k, v in pairs(s) do
      if v == 'tag' then
        sf[k] = true
      else
        tf[k] = compile(v)
      end
      table.insert(ks, k)
    end
    table.sort(ks)
    local err = 'expected one of {' .. table.concat(ks, ', ') .. '}'
    return function(v, product)
      if sf[v] then
        return
      end
      if type(v) ~= 'table' then
        return err
      end
      local vk, vv = next(v)
      if vk == nil then
        return 'missing element, ' .. err
      end
      if next(v, vk) ~= nil then
        return 'multiple elements, ' .. err
      end
      local tfvk = tf[vk]
      if tfvk == nil then
        return 'bad key, ' .. err
      end
      return tfvk(vv, product)
    end
  end,
}

local function docompile(schematype)
  if type(schematype) ~= 'table' then
    error('unexpected schema type ' .. type(schematype))
  end
  local k, v = next(schematype)
  if next(schematype, k) then
    error('multiple keys in schematype')
  end
  return assert(complex[k], 'unknown complex schematype')(v)
end

function compile(schematype)
  return simple[schematype] or docompile(schematype)
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
