describe('apis', function()
  for _, p in ipairs(require('wowless.util').productList()) do
    describe(p, function()
      for name, api in pairs(require('build/data/products/' .. p .. '/apis')) do
        describe(name, function()
          it('has exactly one implementation', function()
            if api.impl then
              for _, output in ipairs(api.outputs or {}) do
                assert.Nil(output.stub, 'implemented apis cannot specify return values')
              end
            end
          end)
        end)
      end
    end)
  end
end)
