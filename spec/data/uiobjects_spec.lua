local yaml = require('wowapi.yaml')

describe('uiobjects', function()
  local expectedImpls = {}
  for _, p in ipairs(require('wowless.util').productList()) do
    describe(p, function()
      local uiobjects = yaml.parseFile('data/products/' .. p .. '/uiobjects.yaml')
      for k, v in pairs(uiobjects) do
        for mk, mv in pairs(v.methods or {}) do
          if mv.status == 'implemented' then
            expectedImpls[('data/uiobjects/%s/%s.lua'):format(k, mk)] = true
          end
        end
      end
      describe('hierarchy', function()
        local g = {}
        for k, v in pairs(uiobjects) do
          local t = {}
          for ik in pairs(v.inherits) do
            t[ik] = true
          end
          g[k] = t
        end
        local nr = {}
        for _, v in pairs(g) do
          for ik in pairs(v) do
            nr[ik] = true
          end
        end
        local function process(t, root, k)
          assert(not t[k], ('multiple paths from %s to %s'):format(root, k))
          t[k] = true
          for ik in pairs(g[k]) do
            process(t, root, ik)
          end
        end
        for k in pairs(g) do
          describe(k, function()
            local t = {}
            it('is a tree', function()
              process(t, k, k)
            end)
            if not nr[k] then
              it('is not virtual', function()
                assert.Nil(uiobjects[k].virtual)
              end)
              it('is a uiobject', function()
                assert.True(t.UIObject)
              end)
            elseif not next(g[k]) then
              it('is virtual', function()
                assert.True(uiobjects[k].virtual)
              end)
            end
          end)
        end
      end)
      local function hasMember(k, m, f)
        local v = uiobjects[k]
        if (v[m] or {})[f] then
          return true
        end
        for inh in pairs(v.inherits) do
          if hasMember(inh, m, f) then
            return true
          end
        end
        return false
      end
      for k, v in pairs(uiobjects) do
        describe(k, function()
          describe('fields', function()
            for fk in pairs(v.fields or {}) do
              describe(fk, function()
                it('is not defined up inheritance tree', function()
                  for inh in pairs(v.inherits) do
                    assert.False(hasMember(inh, 'fields', fk))
                  end
                end)
              end)
            end
          end)
          describe('methods', function()
            for mk, mv in pairs(v.methods) do
              describe(mk, function()
                it('is not defined up inheritance tree', function()
                  for inh in pairs(v.inherits) do
                    assert.False(hasMember(inh, 'methods', mk))
                  end
                end)
                it('manipulates only declared fields', function()
                  for _, field in ipairs(mv.fields or {}) do
                    assert.True(hasMember(k, 'fields', field.name))
                  end
                end)
              end)
            end
          end)
        end)
      end
    end)
  end
  local actualImpls = {}
  for _, f in ipairs(require('pl.dir').getallfiles('data/uiobjects/')) do
    actualImpls[f] = true
  end
  it('has exactly the right impl files', function()
    assert.same(expectedImpls, actualImpls)
  end)
end)
