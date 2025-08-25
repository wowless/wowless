describe('config', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local config = require('build.data.products.' .. p .. '.config')
      local apis = require('build.data.products.' .. p .. '.apis')
      local enums = require('build.data.products.' .. p .. '.globals').Enum
      local ns = {}
      for k in pairs(apis) do
        local dot = k:find('%.')
        if dot then
          ns[k:sub(1, dot - 1)] = true
        end
      end
      describe('addon', function()
        local addoncfg = config.addon or {}
        describe('capsule', function()
          local capsulecfg = addoncfg.capsule or {}
          describe('apinamespaces', function()
            for k in pairs(capsulecfg.apinamespaces or {}) do
              it(k, function()
                assert(ns[k])
              end)
            end
          end)
        end)
        describe('enum_values_set_in_framexml', function()
          for k, v in pairs(addoncfg.enum_values_set_in_framexml or {}) do
            describe(k, function()
              local e = enums[k]
              for vk in pairs(v) do
                describe(vk, function()
                  it('must not exist', function()
                    assert.Nil(e[vk])
                  end)
                end)
              end
            end)
          end
        end)
      end)
    end)
  end
end)
