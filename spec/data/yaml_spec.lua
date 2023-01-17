local plfile = require('pl.file')
local yaml = require('wowapi.yaml')
local validate = require('wowapi.schema').validate

local dirschemas = {
  schemas = 'schema',
  state = 'state',
}

local productschemas = {
  apis = 'apis',
  build = 'build',
  cvars = 'cvars',
  events = 'events',
  globals = 'globals',
  structures = 'structures',
  uiobjects = 'uiobjects',
  xml = 'xml',
}

local products = require('wowless.util').productList()

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
            for _, p in ipairs(products) do
              describe(p, function()
                it('schema validates', function()
                  validate(p, schema, data)
                end)
              end)
            end
          end)
        end
      end
    end)
  end
  for _, p in ipairs(products) do
    local d = 'data/products/' .. p
    for file, schemaname in pairs(productschemas) do
      describe(d .. '/' .. file, function()
        local schema = yaml.parseFile('data/schemas/' .. schemaname .. '.yaml').type
        local str = plfile.read(d .. '/' .. file .. '.yaml')
        local data = yaml.parse(str)
        it('is correctly formatted', function()
          assert.same(str, yaml.pprint(data))
        end)
        it('schema validates', function()
          validate(p, schema, data)
        end)
      end)
    end
  end
end)
