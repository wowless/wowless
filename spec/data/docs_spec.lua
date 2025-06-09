describe('docs', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local docs = require('build.data.products.' .. p .. '.docs')
      describe('lies', function()
        describe('apis', function()
          for k, v in pairs(docs.lies and docs.lies.apis or {}) do
            describe(k, function()
              it('has no impl', function()
                assert.Nil(v.impl)
              end)
            end)
          end
        end)
      end)
    end)
  end
end)
