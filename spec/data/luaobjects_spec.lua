describe('luaobjects', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local luaobjects = require('build.data.products.' .. p .. '.luaobjects')
      describe('hierarchy', function()
        local nr = {}
        for _, v in pairs(luaobjects) do
          if v.inherits then
            nr[v.inherits] = (nr[v.inherits] or 0) + 1
          end
        end
        -- Cycle-freedom is enforced by the luaobjects schema's `hierarchy`
        -- construct.
        for k in pairs(luaobjects) do
          describe(k, function()
            it('is not leaf if virtual', function()
              assert.True(not luaobjects[k].virtual or nr[k] > 0)
            end)
          end)
        end
      end)
      for k, v in pairs(luaobjects) do
        describe(k, function()
          describe('methods', function()
            for mk, mv in pairs(v.methods) do
              describe(mk, function()
                describe('inputs', function()
                  for _, input in ipairs(mv.inputs or {}) do
                    describe(input.name, function()
                      if input.default ~= nil then
                        it('is not explicitly nilable', function()
                          assert.Nil(input.nilable)
                        end)
                      end
                    end)
                  end
                  it('are uniquely named', function()
                    local names = {}
                    for _, input in ipairs(mv.inputs or {}) do
                      assert.Nil(names[input.name])
                      names[input.name] = true
                    end
                  end)
                end)
                describe('outputs', function()
                  it('are uniquely named', function()
                    local names = {}
                    for _, output in ipairs(mv.outputs or {}) do
                      assert.Nil(names[output.name])
                      names[output.name] = true
                    end
                  end)
                end)
              end)
            end
          end)
        end)
      end
    end)
  end
end)
