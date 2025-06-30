describe('apis', function()
  for _, p in ipairs(require('build.data.products')) do
    local wapi = require('wowless.api').new(function() end, 0, p, 0)
    local typechecker = require('wowless.typecheck')(wapi)
    describe(p, function()
      local apis = require('build.data.products.' .. p .. '.apis')
      for name, api in pairs(apis) do
        describe(name, function()
          it('is not stubbed if provided by elune', function()
            if _G[name] then
              assert.Truthy(api.impl or api.alias)
            end
          end)
          describe('inputs', function()
            for k, input in ipairs(api.inputs or {}) do
              describe(k, function()
                if input.type == 'nil' then
                  describe('is typed nil so it', function()
                    it('has no explicit default', function()
                      assert.Nil(input.default)
                    end)
                    it('is not explicitly nilable', function()
                      assert.Nil(input.nilable)
                    end)
                  end)
                end
                if input.default ~= nil then
                  it('default must typecheck', function()
                    local value, errmsg = typechecker(input, input.default, true)
                    assert.Nil(errmsg)
                    assert.same(value, input.default)
                  end)
                end
                if api.impl then
                  it('has a name', function()
                    assert.Not.Nil(input.name)
                  end)
                  it('cannot be unknown type', function()
                    assert.Not.same('unknown', input.type)
                  end)
                end
              end)
            end
            it('either all have names or none have names', function()
              local named = 0
              for _, input in ipairs(api.inputs or {}) do
                named = named + (input.name and 1 or 0)
              end
              assert.True(named == 0 or named == #api.inputs)
            end)
            it('are uniquely named', function()
              local names = {}
              for _, input in ipairs(api.inputs or {}) do
                if input.name then
                  assert.Nil(names[input.name])
                  names[input.name] = true
                end
              end
            end)
          end)
          describe('instride', function()
            it('is less than or equal to number of inputs', function()
              assert(not api.instride or api.instride <= #api.inputs)
            end)
          end)
          describe('outputs', function()
            for k, output in ipairs(api.outputs or {}) do
              describe(k, function()
                if output.type == 'nil' then
                  describe('is typed nil so it', function()
                    it('has no explicit default', function()
                      assert.Nil(output.default)
                    end)
                    it('has no explicit stub', function()
                      assert.Nil(output.stub)
                    end)
                    it('is not explicitly nilable', function()
                      assert.Nil(output.nilable)
                    end)
                    it('is not explicitly stubnotnil', function()
                      assert.Nil(output.nilable)
                    end)
                  end)
                end
                it('cannot be both stubnotnil and have a stub', function()
                  assert.True(not output.stubnotnil or output.stub == nil)
                end)
                it('must be nilable if stubnotnil', function()
                  assert.True(not output.stubnotnil or output.nilable)
                end)
                if output.default ~= nil then
                  it('default must typecheck', function()
                    local value, errmsg = typechecker(output, output.default, true)
                    assert.Nil(errmsg)
                    assert.same(value, output.default)
                  end)
                end
                if output.stub ~= nil then
                  it('stub must typecheck', function()
                    local value, errmsg = typechecker(output, output.stub, true)
                    assert.Nil(errmsg)
                    assert.same(value, output.stub)
                  end)
                end
                if api.impl or output.stub then
                  it('has a name', function()
                    assert.Not.Nil(output.name)
                  end)
                end
                if api.impl then
                  it('cannot specify return value', function()
                    assert.Nil(output.stub)
                  end)
                  it('cannot be unknown type', function()
                    assert.Not.same('unknown', output.type)
                  end)
                end
              end)
            end
            it('either all have names or none have names', function()
              local named = 0
              for _, output in ipairs(api.outputs or {}) do
                named = named + (output.name and 1 or 0)
              end
              assert.True(named == 0 or named == #api.outputs)
            end)
            it('are uniquely named', function()
              local names = {}
              for _, output in ipairs(api.outputs or {}) do
                if output.name then
                  assert.Nil(names[output.name])
                  names[output.name] = true
                end
              end
            end)
          end)
          describe('outstride', function()
            it('is less than or equal to number of outputs', function()
              assert(not api.outstride or api.outstride <= #api.outputs)
            end)
          end)
          describe('stubnothing', function()
            it('is only true if mayreturnnothing', function()
              assert(not api.stubnothing or api.mayreturnnothing)
            end)
          end)
          describe('stuboutstrides', function()
            it('is only set it outstride is set', function()
              assert(not api.stuboutstrides or api.outstride)
            end)
            it('is either zero or greater than 1 if set', function()
              local s = api.stuboutstrides
              assert(not s or s == 0 or s > 1)
            end)
          end)
        end)
      end
      it('has no duplicate stdlibs', function()
        local impls = require('build.data.impl')
        local s = {}
        for k, v in pairs(apis) do
          local z = impls[v.impl] and impls[v.impl].stdlib
          if z then
            if s[z] then
              error(('stdlib %q duplicated across %q and %q'):format(z, k, s[z]))
            end
            s[z] = k
          end
        end
      end)
    end)
  end
end)
