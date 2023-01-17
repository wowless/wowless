local lfs = require('lfs')
local plfile = require('pl.file')
local plpath = require('pl.path')
local yaml = require('wowapi.yaml')

describe('uiobjects', function()
  for entry in lfs.dir('data/uiobjects') do
    if entry ~= '.' and entry ~= '..' then
      local fentry = 'data/uiobjects/' .. entry
      assert(plpath.isdir(fentry), 'invalid entry ' .. entry)
      describe(entry, function()
        local yamlname = fentry .. '/' .. entry .. '.yaml'
        local cfg = assert(yaml.parseFile(yamlname))
        local luas = {}
        for subentry in lfs.dir(fentry) do
          if subentry ~= '.' and subentry ~= '..' then
            if subentry:sub(-4) == '.lua' then
              luas[subentry:sub(1, -5)] = assert(loadfile(fentry .. '/' .. subentry))
            else
              assert(subentry == entry .. '.yaml')
            end
          end
        end
        describe('yaml', function()
          it('is correctly formatted', function()
            assert.same(plfile.read(yamlname), yaml.pprint(cfg))
          end)
          it('has the right name', function()
            assert.same(entry, cfg.name)
          end)
          it('has valid methods', function()
            assert.same('table', type(cfg.methods))
            for k in pairs(luas) do
              assert.Truthy(cfg.methods[k], ('method %q not in yaml'):format(k))
            end
          end)
        end)
      end)
    end
  end

  describe('hierarchy', function()
    local function hasproduct(t, p)
      if not t.products then
        return true
      end
      for _, k in ipairs(t.products) do
        if k == p then
          return true
        end
      end
      return false
    end

    local uiobjects = require('wowapi.data').uiobjects

    for _, p in ipairs(require('wowless.util').productList()) do
      describe(p, function()
        local g = {}
        for k, v in pairs(uiobjects) do
          local t = {}
          for ik, iv in pairs(v.cfg.inherits) do
            t[ik] = hasproduct(iv, p) or nil
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
                assert.Nil(uiobjects[k].cfg.virtual)
              end)
              it('is a uiobject', function()
                assert.True(t.UIObject)
              end)
            elseif not next(g[k]) then
              it('is virtual', function()
                assert.True(uiobjects[k].cfg.virtual)
              end)
            end
          end)
        end
      end)
    end
  end)
end)
