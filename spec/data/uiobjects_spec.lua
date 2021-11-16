local lfs = require('lfs')
local plpath = require('pl.path')
local yaml = require('wowapi.yaml')

describe('uiobjects', function()
  for entry in lfs.dir('data/uiobjects') do
    if entry ~= '.' and entry ~= '..' then
      local fentry = 'data/uiobjects/' .. entry
      assert(plpath.isdir(fentry), 'invalid entry ' .. entry)
      describe(entry, function()
        local cfg = assert(yaml.parseFile(fentry .. '/' .. entry .. '.yaml'))
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
          it('has the right name', function()
            assert.same(entry, cfg.name)
          end)
          it('has only valid fields', function()
            local fields = {
              fields = true,
              inherits = true,
              methods = true,
              name = true,
            }
            for k in pairs(cfg) do
              assert.True(fields[k], ('invalid field %q'):format(k))
            end
          end)
          it('has valid inherits', function()
            assert.same('table', type(cfg.inherits))
          end)
          it('has valid methods', function()
            assert.same('table', type(cfg.methods))
            for k in pairs(luas) do
              assert.Truthy(k == 'init' or cfg.methods[k], ('method %q not in yaml'):format(k))
            end
          end)
          it('has valid fields', function()
            if cfg.fields ~= nil then
              assert.same('table', type(cfg.fields))
              for k, v in pairs(cfg.fields) do
                assert.same('string', type(k))
                assert.same('table', type(v))
                local fields = {
                  type = true
                }
                for k2 in pairs(v) do
                  assert(fields[k2])
                end
                assert.True(v.type == nil or v.type == 'bool')
              end
            end
          end)
        end)
        describe('methods', function()
          for methodname, method in pairs(cfg.methods) do
            describe(methodname, function()
              it('has only valid fields', function()
                local fields = {
                  field = true,
                  outputs = true,
                  status = true,
                  versions = true,
                }
                for k in pairs(method) do
                  assert.True(fields[k], ('invalid field %q'):format(k))
                end
              end)
              it('has valid status', function()
                local valid = {
                  getter = true,
                  implemented = true,
                  setter = true,
                  unimplemented = true,
                }
                assert.True(valid[method.status], ('invalid status %q'):format(method.status))
              end)
              it('has valid outputs', function()
                local valid = {
                  name = true,
                  type = true,
                }
                for _, m in ipairs(method.outputs or {}) do
                  for k in pairs(m) do
                    assert.True(valid[k])
                  end
                  assert.same('string', type(m.type))
                  assert.same('number', m.type)
                end
              end)
              it('has valid versions', function()
                if method.versions ~= nil then
                  assert.same('table', type(method.versions))
                  local valid = {
                    Vanilla = true,
                    TBC = true,
                    Mainline = true,
                  }
                  local seen = {}
                  for _, v in ipairs(method.versions) do
                    assert.True(valid[v])
                    assert.Nil(seen[v])
                    seen[v] = true
                  end
                end
              end)
            end)
          end
        end)
      end)
    end
  end
end)
