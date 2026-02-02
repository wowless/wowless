local validate
do
  local inner = require('wowapi.schema').validate
  local pretty = require('wowapi.yaml').pprint
  function validate(...)
    assert(xpcall(inner, pretty, ...))
  end
end

local globalschemas = {
  ['data/families'] = 'families',
  ['data/gametypes'] = 'gametypes',
  ['data/impl'] = 'impl',
  ['data/modules'] = 'modules',
  ['data/products'] = 'products',
  ['data/sql'] = 'sql',
  ['data/stringenums'] = 'stringenums',
  ['data/test'] = 'test',
  ['data/uiobjectimpl'] = 'uiobjectimpl',
}

local dirschemas = {
  schemas = 'schema',
}

local productschemas = {
  apis = 'apis',
  build = 'build',
  config = 'config',
  cvars = 'cvars',
  docs = 'docs',
  events = 'events',
  globals = 'globals',
  luaobjects = 'luaobjects',
  structures = 'structures',
  uiobjects = 'uiobjects',
  xml = 'xml',
}

local products = require('build.data.products')

describe('yaml', function()
  for dir, schemaname in pairs(dirschemas) do
    describe(dir, function()
      local schema = require('build.data.schemas.' .. schemaname).type
      for f in require('lfs').dir('data/' .. dir) do
        if f ~= '.' and f ~= '..' then
          assert(f:sub(-5) == '.yaml')
          local name = f:sub(1, -6)
          describe(f, function()
            local data = require('build.data.' .. dir .. '.' .. name)
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
  for file, schemaname in pairs(globalschemas) do
    describe(file, function()
      local schema = require('build.data.schemas.' .. schemaname).type
      local data = require('wowapi.yaml').parseFile(file .. '.yaml')
      it('schema validates', function()
        validate('not a product', schema, data)
      end)
    end)
  end
  for _, p in ipairs(products) do
    local d = 'data.products.' .. p
    for file, schemaname in pairs(productschemas) do
      describe(d .. '/' .. file, function()
        local schema = require('build.data.schemas.' .. schemaname).type
        local data = require('build.' .. d .. '.' .. file)
        it('schema validates', function()
          validate(p, schema, data)
        end)
      end)
    end
  end
end)
