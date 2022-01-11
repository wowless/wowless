describe('xml', function()
  local lang = require('wowapi.data').xml
  it('has no entries with a field named "type"', function()
    for k, v in pairs(lang) do
      assert.True(not v.fields or not v.fields.type, k)
    end
  end)
end)
