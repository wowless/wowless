describe('apis', function()
  local data = require('wowapi.data')
  local parseYaml = require('wowapi.yaml').parseFile
  for _, p in ipairs(require('wowless.util').productList()) do
    describe(p, function()
      for name, api in pairs(parseYaml('data/products/' .. p .. '/apis.yaml')) do
        describe(name, function()
          it('has exactly one implementation', function()
            if api.impl then
              assert.Not.Nil(data.impl[api.impl], 'implemented apis must have an implementation')
              for _, output in ipairs(api.outputs or {}) do
                assert.Nil(output.stub, 'implemented apis cannot specify return values')
              end
            elseif not api.alias and not api.stdlib then
              assert.Nil(api.frameworks, 'unimplemented apis cannot specify frameworks')
              assert.Nil(api.states, 'unimplemented apis cannot specify states')
            end
          end)
        end)
      end
    end)
  end
end)
