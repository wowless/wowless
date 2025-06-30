describe('structures', function()
  for _, p in ipairs(require('build.data.products')) do
    local api = require('wowless.api').new(function() end, 0, p, 0)
    local typechecker = require('wowless.typecheck')(api)
    local function typecheck(spec, val)
      local value, errmsg = typechecker(spec, val, true)
      assert.Nil(errmsg)
      assert.same(value, val)
    end
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
      for _, v in pairs(require('build.data.products.' .. p .. '.apis')) do
        reflist(v.inputs)
        reflist(v.outputs)
      end
      for _, v in pairs(require('build.data.products.' .. p .. '.events')) do
        for _, pv in ipairs(v.payload or {}) do
          refty(pv.type)
        end
      end
      for _, v in pairs(require('build.data.products.' .. p .. '.uiobjects')) do
        for _, m in pairs(v.methods) do
          reflist(m.inputs)
          reflist(m.outputs)
        end
      end
      local actual = require('build.data.products.' .. p .. '.structures')
      local expected = {}
      local function close(ty)
        if ty.arrayof then
          close(ty.arrayof)
        elseif ty.structure then
          if not expected[ty.structure] then
            expected[ty.structure] = true
            for _, fv in pairs((actual[ty.structure] or {}).fields) do
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
      for k, v in pairs(actual) do
        describe(k, function()
          for fk, fv in pairs(v.fields) do
            describe(fk, function()
              if fv.default ~= nil then
                it('has default of the right type', function()
                  typecheck(fv, fv.default)
                end)
              end
              if fv.stub ~= nil then
                it('has stub of the right type', function()
                  typecheck(fv, fv.stub)
                end)
              end
            end)
          end
        end)
      end
    end)
  end
end)
