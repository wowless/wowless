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
      local function ref(refs, x)
        if x and not nonStructs[x] then
          refs[x] = true
        end
      end
      local function reflist(refs, xs)
        for _, x in ipairs(xs or {}) do
          ref(refs, x.type)
          ref(refs, x.innerType)
        end
      end
      local expected = {}
      for _, api in pairs(parseYaml('data/products/' .. p .. '/apis.yaml')) do
        for _, il in ipairs(api.inputs or {}) do
          reflist(expected, il)
        end
        reflist(expected, api.outputs)
      end
      for _, v in pairs(parseYaml('data/products/' .. p .. '/events.yaml')) do
        for _, pv in ipairs(v.payload or {}) do
          ref(expected, pv.type.structure)
          ref(expected, pv.type.arrayof)
        end
      end
      local actual = {}
      for k, v in pairs(parseYaml('data/products/' .. p .. '/structures.yaml')) do
        actual[k] = true
        for _, fv in pairs(v) do
          ref(expected, fv.type.structure)
          ref(expected, fv.type.arrayof)
        end
      end
      describe('exists', function()
        for k in pairs(expected) do
          it(k, function()
            assert.True(actual[k])
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
