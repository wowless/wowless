describe('structures', function()
  local parseYaml = require('wowapi.yaml').parseFile
  for _, p in ipairs(require('wowless.util').productList()) do
    describe(p, function()
      local refs = {}
      local function ref(xs)
        for _, x in ipairs(xs) do
          refs[x.type] = true
          if x.innerType then
            refs[x.innerType] = true
          end
        end
      end
      for _, api in pairs(parseYaml('data/products/' .. p .. '/apis.yaml')) do
        for _, il in ipairs(api.inputs or {}) do
          ref(il)
        end
        ref(api.outputs or {})
      end
      for _, v in pairs(parseYaml('data/products/' .. p .. '/events.yaml')) do
        ref(v.payload or {})
      end
      local structures = parseYaml('data/products/' .. p .. '/structures.yaml')
      local closure = {}
      local function close(t)
        if structures[t] and not closure[t] then
          closure[t] = true
          for _, f in ipairs(structures[t].fields) do
            close(f.type)
            if f.innerType then
              close(f.innerType)
            end
          end
        end
      end
      for k in pairs(refs) do
        close(k)
      end
      --[[
      -- Uncomment this to fix up the structures file.
      local x = {}
      for k in pairs(closure) do
        x[k] = structures[k]
      end
      require('pl.file').write('data/products/' .. p .. '/structures.yaml', require('wowapi.yaml').pprint(x))
]]
      --
      for k in pairs(structures) do
        describe(k, function()
          it('is in use', function()
            assert.True(closure[k])
          end)
        end)
      end
    end)
  end
end)
