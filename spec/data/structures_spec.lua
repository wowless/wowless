describe('structures', function()
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
      for _, api in pairs(require('build/data/products/' .. p .. '/apis')) do
        for _, il in ipairs(api.inputs or {}) do
          reflist(il)
        end
        reflist(api.outputs)
      end
      for _, v in pairs(require('build/data/products/' .. p .. '/events')) do
        for _, pv in ipairs(v.payload or {}) do
          refty(pv.type)
        end
      end
      local actual = require('build/data/products/' .. p .. '/structures')
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
          assert(ty.enum or type(ty) == 'string', 'weird type ' .. tostring(ty))
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
