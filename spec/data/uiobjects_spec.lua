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
        end)
        describe('methods', function()
          for methodname, method in pairs(cfg.methods) do
            describe(methodname, function()
              it('has only valid fields', function()
                local fields = {
                  outputs = true,
                  status = true,
                }
                for k in pairs(method) do
                  assert.True(fields[k], ('invalid field %q'):format(k))
                end
              end)
              it('has valid status', function()
                local valid = {
                  implemented = true,
                  unimplemented = true,
                }
                assert.True(valid[method.status], ('invalid status %q'):format(method.status))
              end)
            end)
          end
        end)
      end)
    end
  end
end)
