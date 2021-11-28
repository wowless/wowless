describe('loader', function()
  local loader = require('wowapi.loader')

  for _, v in ipairs({'Vanilla', 'TBC', 'Mainline'}) do
    it('loads ' .. v, function()
      assert.same('table', type(loader.loadFunctions(v, {}, nil, {})))
    end)
  end

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
