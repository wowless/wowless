describe('loader', function()
  local loader = require('wowapi.loader')

  it('loads', function()
    assert.same('table', type(loader.loadFunctions('data/api')))
  end)

  describe('argSig', function()
    it('handles all types', function()
      local b = true
      local f = function() end
      local n = 1
      local s = 'foo'
      local t = {}
      local u = newproxy()
      assert.same('xbfnstu', loader.argSig('name', nil, b, f, n, s, t, u, nil))
    end)
  end)

  describe('getFn', function()
    it('works with null stub results', function()
      local api = require('wowapi.yaml').parse([[
---
name: Foo
status: stub
returns:
  - null
  - 42
  - null
]])
      local modules = {}
      local fn = loader.getFn(api, modules)
      assert.same({nil, 42, nil}, {fn()})
    end)
  end)
end)
