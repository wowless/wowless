local function validate(schematype, v)
  if schematype == 'any' then
    return
  elseif schematype == 'string' then
    assert(type(v) == 'string', 'expected string')
  elseif type(schematype) ~= 'table' then
    error('expected type table')
  elseif schematype.record then
    assert(type(v) == 'table', 'expected table')
    -- TODO required/optional fields
    for k2, v2 in pairs(v) do
      local k2ty = schematype.record[k2]
      assert(k2ty, 'unknown field ' .. k2)
      validate(k2ty, v2)
    end
  elseif schematype.mapof then
    assert(type(v) == 'table', 'expected table')
    for _, v2 in pairs(v) do
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
    error('unsupported')
  else
    error('expected record/mapof/sequenceof/oneof')
  end
end

return {
  validate = validate,
}
