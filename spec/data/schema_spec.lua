local plfile = require('pl.file')
local yaml = require('wowapi.yaml')

describe('schemas', function()
  for f in require('lfs').dir('data/schemas') do
    if f ~= '.' and f ~= '..' then
      assert(f:sub(-5) == '.yaml')
      describe(f, function()
        local str = plfile.read('data/schemas/' .. f)
        local data = yaml.parse(str)
        it('is correctly formatted', function()
          assert.same(str, yaml.pprint(data))
        end)
      end)
    end
  end
end)
