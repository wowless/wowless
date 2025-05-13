describe('docs', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local docs = require('build.data.products.' .. p .. '.docs')
      local uiobjects = require('build.data.products.' .. p .. '.uiobjects')
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
      describe('uiobject_methods', function()
        for k, v in pairs(docs.uiobject_methods or {}) do
          describe(k, function()
            it('is not also in docs uiobjects', function()
              assert.Nil(docs.uiobjects and docs.uiobjects[k])
            end)
            local um = assert(uiobjects[k]).methods or {}
            for mk in pairs(v) do
              describe(mk, function()
                it('exists in uiobject config', function()
                  assert(um[mk])
                end)
              end)
            end
          end)
        end
      end)
    end)
  end
end)
