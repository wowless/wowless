local plfile = require('pl.file')
local yaml = require('wowapi.yaml')
local validate = require('wowapi.schema').validate

local dirschemas = {
  api = 'api',
  state = 'state',
}

describe('yaml', function()
  for dir, schemaname in pairs(dirschemas) do
    describe(dir, function()
      local schema = yaml.parseFile('data/schemas/' .. schemaname .. '.yaml').type
      for f in require('lfs').dir('data/' .. dir) do
        if f ~= '.' and f ~= '..' then
          assert(f:sub(-5) == '.yaml')
          local name = f:sub(1, -6)
          describe(f, function()
            local str = plfile.read('data/' .. dir .. '/' .. f)
            local data = yaml.parse(str)
            it('is correctly formatted', function()
              assert.same(str, yaml.pprint(data))
            end)
            it('has the right name', function()
              assert.same(name, data.name)
            end)
            it('schema validates', function()
              validate(schema, data)
            end)
          end)
        end
      end
    end)
  end
end)
