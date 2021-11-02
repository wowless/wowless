describe('init', function()
  local wowapi = require('wowapi.loader')

  it('loads', function()
    assert.same('table', type(wowapi.loadFunctions('data/api')))
  end)

  describe('argSig', function()
    it('handles all types', function()
      local b = true
      local f = function() end
      local n = 1
      local s = 'foo'
      local t = {}
      local u = newproxy()
      assert.same('xbfnstu', wowapi.argSig('name', nil, b, f, n, s, t, u, nil))
    end)
  end)
end)
