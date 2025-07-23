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

local function validate(product, schematype, v)
  if schematype == 'number' then
    assert(type(v) == 'number', 'expected number')
  elseif schematype == 'string' then
    assert(type(v) == 'string', 'expected string')
  elseif schematype == 'boolean' then
    assert(type(v) == 'boolean', 'expected boolean')
  elseif schematype == 'table' then
    assert(type(v) == 'table', 'expected table')
  elseif type(schematype) ~= 'table' then
    error('unexpected schema type ' .. tostring(schematype))
  elseif schematype.schema then
    local schema = wdata.schemas[schematype.schema]
    assert(schema and schema.type, 'bad schema: ' .. schematype.schema)
    validate(product, schema.type, v)
  elseif schematype.record then
    assert(type(v) == 'table', 'expected table')
    for k2, v2 in pairs(v) do
      local info = schematype.record[k2]
      assert(info, 'unknown field ' .. k2)
      validate(product, info.type, v2)
    end
    for field, info in pairs(schematype.record) do
      assert(not info.required or v[field] ~= nil, 'missing required field ' .. field)
    end
  elseif schematype.mapof then
    local kty = assert(schematype.mapof.key, 'missing key type')
    local vty = assert(schematype.mapof.value, 'missing value type')
    assert(type(v) == 'table', 'expected table')
    for k2, v2 in pairs(v) do
      validate(product, kty, k2)
      validate(product, vty, v2)
    end
  elseif schematype.sequenceof then
    assert(type(v) == 'table', 'expected table')
    local max = 0
    for k2, v2 in pairs(v) do
      assert(type(k2) == 'number', 'expected number key')
      max = k2 > max and k2 or max
      validate(product, schematype.sequenceof, v2)
    end
    assert(max == #v, 'expected array')
  elseif schematype.oneof then
    local errors = {}
    for _, ty in ipairs(schematype.oneof) do
      local success, err = pcall(validate, product, ty, v)
      if success then
        return
      else
        table.insert(errors, err)
      end
    end
    error('did not validate against any element of oneof: ' .. require('pl.pretty').write(errors))
  elseif schematype.literal then
    assert(type(v) == 'string', 'expected string')
    assert(v == schematype.literal, 'string literal mismatch')
  elseif schematype.ref then
    assert(type(v) == 'string', 'expected string in ref')
    local ref = schematype.ref
    local domain = domains[ref] or productDomains[ref] and productDomains[ref][product]
    assert(domain, 'bad schema: invalid domain')
    assert(domain[v], 'unknown domain value ' .. v)
  else
    error('expected record/mapof/sequenceof/oneof')
  end
end

return {
  validate = validate,
}
