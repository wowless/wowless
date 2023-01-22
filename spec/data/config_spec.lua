describe('config', function()
  local parseYaml = require('wowapi.yaml').parseFile
  for _, p in ipairs(require('wowless.util').productList()) do
    describe(p, function()
      local config = parseYaml('data/products/' .. p .. '/config.yaml')
      local apis = parseYaml('data/products/' .. p .. '/apis.yaml')
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
