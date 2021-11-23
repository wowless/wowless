local lfs = require('lfs')
local plfile = require('pl.file')
local plpath = require('pl.path')
local yaml = require('wowapi.yaml')
local schema = yaml.parseFile('data/schemas/uiobject.yaml').type
local validate = require('wowapi.schema').validate

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
          it('schema validates', function()
            validate(schema, cfg)
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
