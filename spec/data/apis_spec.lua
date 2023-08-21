describe('apis', function()
  for _, p in ipairs(require('wowless.util').productList()) do
    local wapi = require('wowless.api').new(function() end, 0, p)
    local typechecker = require('wowless.typecheck')(wapi)
    describe(p, function()
      for name, api in pairs(require('build/data/products/' .. p .. '/apis')) do
        describe(name, function()
          it('is not stubbed if provided by elune', function()
            if _G[name] then
              assert.Truthy(api.impl or api.stdlib or api.alias)
            end
          end)
          if api.impl then
            describe('inputs', function()
              for _, input in ipairs(api.inputs or {}) do
                describe(input.name, function()
                  it('cannot be unknown type', function()
                    assert.Not.same('unknown', input.type)
                  end)
                end)
              end
            end)
          end
          describe('outputs', function()
            for _, output in ipairs(api.outputs or {}) do
              describe(output.name, function()
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
