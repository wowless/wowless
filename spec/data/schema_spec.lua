local plfile = require('pl.file')
local yaml = require('wowapi.yaml')

describe('schema', function()
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
      end)
    end
  end
end)
