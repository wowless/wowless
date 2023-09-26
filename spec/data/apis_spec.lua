describe('apis', function()
  for _, p in ipairs(require('build.data.products')) do
    local wapi = require('wowless.api').new(function() end, 0, p)
    local typechecker = require('wowless.typecheck')(wapi)
    describe(p, function()
      for name, api in pairs(require('build.data.products.' .. p .. '.apis')) do
        describe(name, function()
          it('is not stubbed if provided by elune', function()
            if _G[name] then
              assert.Truthy(api.impl or api.stdlib or api.alias)
            end
          end)
          describe('inputs', function()
            for k, input in ipairs(api.inputs or {}) do
              describe(k, function()
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
          end)
          describe('outputs', function()
            for k, output in ipairs(api.outputs or {}) do
              describe(k, function()
                if output.default ~= nil then
                  it('default must typecheck', function()
                    local value, errmsg = typechecker(output, output.default)
                    assert.Nil(errmsg)
                    assert.same(value, output.default)
                  end)
                end
                if output.stub ~= nil then
                  it('stub must typecheck', function()
                    local value, errmsg = typechecker(output, output.stub)
                    assert.Nil(errmsg)
                    assert.same(value, output.stub)
                  end)
                end
                if api.impl then
                  it('has a name', function()
                    assert.Not.Nil(output.name)
                  end)
                  it('cannot specify return value', function()
                    assert.Nil(output.stub)
                  end)
                  it('cannot be unknown type', function()
                    assert.Not.same('unknown', output.type)
                  end)
                end
              end)
            end
          end)
        end)
      end
    end)
  end
end)
