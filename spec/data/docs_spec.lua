describe('docs', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local docs = require('build.data.products.' .. p .. '.docs')
      local apis = require('build.data.products.' .. p .. '.apis')
      describe('lies', function()
        local lies = docs.lies or {}
        describe('extra_apis', function()
          for k in pairs(lies.extra_apis or {}) do
            describe(k, function()
              it('must not be a global api', function()
                assert.Nil(apis[k])
              end)
            end)
          end
        end)
      end)
    end)
  end
end)
