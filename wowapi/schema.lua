local wdata = require('wowapi.data')
local domains = {
  schema = wdata.schemas,
  state = wdata.state,
  structure = wdata.structures,
  uiobject = wdata.uiobjects,
}

local function validate(schematype, v)
  if schematype == 'any' then
    return
  elseif schematype == 'string' then
    assert(type(v) == 'string', 'expected string')
  elseif schematype == 'boolean' then
    assert(type(v) == 'boolean', 'expected boolean')
  elseif type(schematype) ~= 'table' then
    error('unexpected schema type ' .. tostring(schematype))
  elseif schematype.schema then
    local schema = wdata.schemas[schematype.schema]
    assert(schema and schema.type, 'bad schema: ' .. schematype.schema)
    validate(schema.type, v)
  elseif schematype.record then
    assert(type(v) == 'table', 'expected table')
    for k2, v2 in pairs(v) do
      local info = schematype.record[k2]
      assert(info, 'unknown field ' .. k2)
      validate(info.type, v2)
    end
    for field, info in pairs(schematype.record) do
      assert(not info.required or v[field], 'missing required field ' .. field)
    end
  elseif schematype.mapof then
    assert(type(v) == 'table', 'expected table')
    for k2, v2 in pairs(v) do
      assert(type(k2) == 'string', 'expected string key')
      validate(schematype.mapof, v2)
    end
  elseif schematype.sequenceof then
    assert(type(v) == 'table', 'expected table')
    local max = 0
    for k2, v2 in pairs(v) do
      assert(type(k2) == 'number', 'expected number key')
      max = k2 > max and k2 or max
      validate(schematype.sequenceof, v2)
    end
    assert(max == #v, 'expected array')
  elseif schematype.oneof then
    for _, ty in ipairs(schematype.oneof) do
      if pcall(function() validate(ty, v) end) then
        return
      end
    end
    error('did not validate against any element of oneof')
  elseif schematype.literal then
    assert(type(v) == 'string', 'expected string')
    assert(v == schematype.literal, 'string literal mismatch')
  elseif schematype.enumset then
    assert(type(v) == 'table', 'expected table for enumset')
    local values = {}
    for _, vv in ipairs(schematype.enumset.values) do
      values[vv] = true
    end
    local seen = {}
    for _, vv in ipairs(v) do
      assert(type(vv) == 'string', 'expected string value in enumset')
      assert(values[vv], 'unknown value ' .. vv)
      assert(not seen[vv], 'duplicate value ' .. vv)
      seen[vv] = true
    end
    assert(not schematype.enumset.nonempty or next(seen), 'missing value in enumset')
  elseif schematype.ref then
    assert(type(v) == 'string', 'expected string in ref')
    local domain = assert(domains[schematype.ref], 'bad schema: invalid domain')
    assert(domain[v], 'unknown domain value ' .. v)
  else
    error('expected record/mapof/sequenceof/oneof')
  end
end

return {
  validate = validate,
}
