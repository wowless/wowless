describe('state', function()
  local yaml = require('wowapi.yaml')
  for filename in require('lfs').dir('data/state') do
    if filename ~= '.' and filename ~= '..' then
      describe(filename, function()
        assert(filename:sub(-5) == '.yaml', 'invalid file ' .. filename)
        local str = (function()
          local file = io.open('data/state/' .. filename, 'r')
          local str = file:read('*all')
          file:close()
          return str
        end)()
        local t = yaml.parse(str)
        it('is formatted correctly', function()
          assert.same(str, yaml.pprint(t))
        end)
        it('has the right name', function()
          assert.same(filename:sub(1, -6), t.name)
        end)
        it('has a value', function()
          assert.Not.Nil(t.value)
        end)
        it('has no extraneous fields', function()
          local fields = {
            name = true,
            value = true,
          }
          for k in pairs(t) do
            assert.True(fields[k], ('unexpected field %q'):format(k))
          end
        end)
      end)
    end
  end
end)
