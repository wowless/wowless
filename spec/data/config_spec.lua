describe('config', function()
  for _, p in ipairs(require('build.data.products')) do
    describe(p, function()
      local config = require('build/data/products/' .. p .. '/config')
      local apis = require('build/data/products/' .. p .. '/apis')
      local globals = require('build/data/products/' .. p .. '/globals')
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
          describe('enums', function()
            local enums = globals.Enum or {}
            for k in pairs(capsulecfg.enums or {}) do
              it(k, function()
                assert(enums[k])
              end)
            end
          end)
        end)
      end)
      describe('docs', function()
        local doccfg = config.docs or {}
        describe('apis', function()
          local apicfg = doccfg.apis or {}
          describe('skip_namespaces', function()
            local skipcfg = apicfg.skip_namespaces or {}
            local allns = {}
            for k in pairs(apis) do
              local dotpos = k:find('%.')
              if dotpos then
                allns[k:sub(1, dotpos - 1)] = true
              end
            end
            for k in pairs(skipcfg) do
              describe(k, function()
                it('must be unused', function()
                  assert.Nil(allns[k])
                end)
              end)
            end
          end)
        end)
      end)
    end)
  end
end)
