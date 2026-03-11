describe('docs', function()
  local runDocChunk = require('tools.docenv').runDocChunk
  local product = 'wow'

  it('fails on schema validation failure', function()
    local fn = assert(loadstring('APIDocumentation:AddDocumentationTable({ BadField = "bad" })'))
    local ok = pcall(runDocChunk, product, {}, 'test.lua', fn)
    assert.False(ok)
  end)

  it('succeeds with valid schema', function()
    local fn = assert(loadstring('APIDocumentation:AddDocumentationTable({ Name = "Test", Type = "System" })'))
    local ok = pcall(runDocChunk, product, {}, 'test.lua', fn)
    assert.True(ok)
  end)
end)
