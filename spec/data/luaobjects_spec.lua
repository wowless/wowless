describe('luaobjects', function()
  for _, p in ipairs(require('build.data.products')) do
    local typechecker = require('wowless.modules')({
      datalua = require('build.products.' .. p .. '.data'),
    }).typecheck
    local function typecheck(spec, val)
      local value, errmsg = typechecker(spec, val, true)
      assert.Nil(errmsg)
      assert.same(value, val)
    end
    describe(p, function()
      local luaobjects = require('build.data.products.' .. p .. '.luaobjects')
      describe('hierarchy', function()
        local nr = {}
        for _, v in pairs(luaobjects) do
          if v.inherits then
            nr[v.inherits] = (nr[v.inherits] or 0) + 1
          end
        end
        local function process(t, root, k)
          assert(not t[k], ('cycle from %s to %s'):format(root, k))
          t[k] = true
          local parent = luaobjects[k] and luaobjects[k].inherits
          if parent then
            process(t, root, parent)
          end
        end
        for k in pairs(luaobjects) do
          describe(k, function()
            local t = {}
            it('is a chain', function()
              process(t, k, k)
            end)
            if not nr[k] then
              it('is not virtual', function()
                assert.Nil(luaobjects[k].virtual)
              end)
            else
              it('is used more than once if virtual', function()
                assert.True(not luaobjects[k].virtual or nr[k] > 1)
              end)
            end
          end)
        end
      end)
      local function hasMember(k, f)
        local v = luaobjects[k]
        if v.methods[f] then
          return true
        end
        if v.inherits then
          return hasMember(v.inherits, f)
        end
        return false
      end
      for k, v in pairs(luaobjects) do
        describe(k, function()
          describe('methods', function()
            for mk, mv in pairs(v.methods) do
              describe(mk, function()
                it('is not defined up inheritance tree', function()
                  if v.inherits then
                    assert.False(hasMember(v.inherits, mk))
                  end
                end)
                describe('inputs', function()
                  for _, input in ipairs(mv.inputs or {}) do
                    describe(input.name, function()
                      if input.default ~= nil then
                        it('has default of the right type', function()
                          typecheck(input, input.default)
                        end)
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
