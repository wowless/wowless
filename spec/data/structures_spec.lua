describe('structures', function()
  local parseYaml = require('wowapi.yaml').parseFile
  local nonStructs = {
    boolean = true,
    ['function'] = true,
    ['nil'] = true,
    number = true,
    ['oneornil'] = true,
    string = true,
    table = true,
    unit = true,
    unknown = true,
    userdata = true,
  }
  for _, p in ipairs(require('wowless.util').productList()) do
    describe(p, function()
      local refs = {}
      local function ref(x)
        if x and not nonStructs[x] then
          refs[x] = true
        end
      end
      local function reflist(xs)
        for _, x in ipairs(xs or {}) do
          ref(x.type)
          ref(x.innerType)
        end
      end
      for _, api in pairs(parseYaml('data/products/' .. p .. '/apis.yaml')) do
        for _, il in ipairs(api.inputs or {}) do
          reflist(il)
        end
        reflist(api.outputs)
      end
      for _, v in pairs(parseYaml('data/products/' .. p .. '/events.yaml')) do
        for _, pv in ipairs(v.payload or {}) do
          ref(pv.type.structure)
          ref(pv.type.arrayof)
        end
      end
      local actual = parseYaml('data/products/' .. p .. '/structures.yaml')
      local expected = {}
      local function close(k)
        if k and not nonStructs[k] and not expected[k] then
          expected[k] = true
          for _, fv in pairs(actual[k] or {}) do
            close(fv.type.structure)
            close(fv.type.arrayof)
          end
        end
      end
      for k in pairs(refs) do
        close(k)
      end
      describe('exists', function()
        for k in pairs(expected) do
          it(k, function()
            assert.Not.Nil(actual[k])
          end)
        end
      end)
      describe('reffed', function()
        for k in pairs(actual) do
          it(k, function()
            assert.True(expected[k])
          end)
        end
      end)
    end)
  end
end)
