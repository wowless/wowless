describe('uiobjects', function()
  for _, p in ipairs(require('build.data.products')) do
    local api = require('wowless.api').new(function() end, 0, p)
    local typechecker = require('wowless.typecheck')(api)
    local function typecheck(spec, val)
      local value, errmsg = typechecker(spec, val, true)
      assert.Nil(errmsg)
      assert.same(value, val)
    end
    describe(p, function()
      local uiobjects = require('build.data.products.' .. p .. '.uiobjects')
      describe('hierarchy', function()
        local g = {}
        for k, v in pairs(uiobjects) do
          local t = {}
          for ik in pairs(v.inherits) do
            t[ik] = true
          end
          g[k] = t
        end
        local nr = {}
        for _, v in pairs(g) do
          for ik in pairs(v) do
            nr[ik] = (nr[ik] or 0) + 1
          end
        end
        local function process(t, root, k)
          assert(not t[k], ('multiple paths from %s to %s'):format(root, k))
          t[k] = true
          for ik in pairs(g[k]) do
            process(t, root, ik)
          end
        end
        for k in pairs(g) do
          describe(k, function()
            local t = {}
            it('is a tree', function()
              process(t, k, k)
            end)
            if not nr[k] then
              it('is not virtual', function()
                assert.Nil(uiobjects[k].virtual)
              end)
              it('is a uiobject', function()
                assert.True(t.UIObject)
              end)
            else
              it('is virtual or uiobject', function()
                assert.True(uiobjects[k].virtual or t.UIObject)
              end)
              it('is used more than once if virtual', function()
                assert.True(not uiobjects[k].virtual or nr[k] > 1)
              end)
            end
          end)
        end
      end)
      local function hasMember(k, m, f)
        local v = uiobjects[k]
        if (v[m] or {})[f] then
          return true
        end
        for inh in pairs(v.inherits) do
          if hasMember(inh, m, f) then
            return true
          end
        end
        return false
      end
      for k, v in pairs(uiobjects) do
        describe(k, function()
          describe('fields', function()
            for fk, fv in pairs(v.fields or {}) do
              describe(fk, function()
                it('is not defined up inheritance tree', function()
                  for inh in pairs(v.inherits) do
                    assert.False(hasMember(inh, 'fields', fk))
                  end
                end)
                it('has initial value of the right type', function()
                  if fv.type ~= 'hlist' then
                    typecheck(fv, fv.init)
                  end
                end)
              end)
            end
          end)
          describe('methods', function()
            for mk, mv in pairs(v.methods) do
              describe(mk, function()
                it('is not defined up inheritance tree', function()
                  for inh in pairs(v.inherits) do
                    assert.False(hasMember(inh, 'methods', mk))
                  end
                end)
                it('manipulates only declared fields', function()
                  for _, field in ipairs(mv.getter or mv.setter or {}) do
                    assert.True(hasMember(k, 'fields', field.name))
                  end
                end)
                describe('inputs', function()
                  for i, input in ipairs(mv.inputs or {}) do
                    describe(input.name or i, function()
                      if input.default ~= nil then
                        it('has default of the right type', function()
                          typecheck(input, input.default)
                        end)
                      end
                    end)
                  end
                end)
                describe('outputs', function()
                  for i, output in ipairs(mv.outputs or {}) do
                    describe(output.name or i, function()
                      if output.stub ~= nil then
                        it('has stub of the right type', function()
                          typecheck(output, output.stub)
                        end)
                      end
                    end)
                  end
                end)
              end)
            end
          end)
        end)
      end
    end)
  end
end)
