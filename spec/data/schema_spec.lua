local plfile = require('pl.file')
local yaml = require('wowapi.yaml')

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
      validate(assert(schematype.record[k2], 'unknown field ' .. k2), v2)
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

describe('schema', function()
  local schemas = {}

  for f in require('lfs').dir('data/schemas') do
    if f ~= '.' and f ~= '..' then
      assert(f:sub(-5) == '.yaml')
      local name = f:sub(1, -6)
      describe(f, function()
        local str = plfile.read('data/schemas/' .. f)
        local schema = yaml.parse(str)
        it('is correctly formatted', function()
          assert.same(str, yaml.pprint(schema))
        end)
        it('has the right name', function()
          assert.same(name, schema.name)
        end)
        schemas[name] = schema
      end)
    end
  end

  describe('api', function()
    it('validates something sane', function()
      validate(schemas.api.type, {})
    end)
  end)

  describe('state', function()
    it('validates something sane', function()
      validate(schemas.state.type, {})
    end)
  end)

  describe('structure', function()
    it('validates something sane', function()
      validate(schemas.structure.type, {})
    end)
  end)

  describe('uiobject', function()
    it('validates something sane', function()
      validate(schemas.uiobject.type, {})
    end)
  end)
end)
