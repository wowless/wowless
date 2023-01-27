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
      local function refty(ty)
        if ty.arrayof then
          refty(ty.arrayof)
        elseif ty.structure then
          refs[ty.structure] = true
        end
      end
      local function reflist(xs)
        for _, x in ipairs(xs or {}) do
          refty(x.type)
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
          refty(pv.type)
        end
      end
      local actual = parseYaml('data/products/' .. p .. '/structures.yaml')
      local expected = {}
      local function close(ty)
        if ty.arrayof then
          close(ty.arrayof)
        elseif ty.structure then
          if not expected[ty.structure] then
            expected[ty.structure] = true
            for _, fv in pairs(actual[ty.structure] or {}) do
              close(fv.type)
            end
          end
        else
          assert(nonStructs[ty], 'weird type ' .. tostring(ty))
        end
      end
      for k in pairs(refs) do
        close({ structure = k })
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
