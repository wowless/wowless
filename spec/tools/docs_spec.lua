describe('docs', function()
  local schema = require('wowapi.yaml').parseFile('data/schemas/doctable.yaml').type
  local pprintYaml = require('wowapi.yaml').pprint
  local validate = require('wowapi.schema').validate
  local product = 'wow'

  local function processDocLua(code)
    local fn = assert(loadstring(code))
    local docs = {}
    local f = 'test.lua'
    local success, err = pcall(setfenv(fn, {
      APIDocumentation = {
        AddDocumentationTable = function(_, t)
          assert(xpcall(validate, pprintYaml, product, schema, t))
          docs[f] = t
        end,
      },
    }))
    if not success then
      error(err, 0)
    end
    return docs
  end

  it('fails on schema validation failure', function()
    local ok = pcall(processDocLua, 'APIDocumentation:AddDocumentationTable({ BadField = "bad" })')
    assert.False(ok)
  end)

  it('succeeds with valid schema', function()
    local ok = pcall(processDocLua, 'APIDocumentation:AddDocumentationTable({ Name = "Test", Type = "System" })')
    assert.True(ok)
  end)
end)
