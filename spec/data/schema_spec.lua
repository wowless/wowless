local plfile = require('pl.file')
local yaml = require('wowapi.yaml')
local validate = require('wowapi.schema').validate

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
