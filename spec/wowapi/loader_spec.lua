describe('loader', function()
  local loader = require('wowapi.loader')

  for _, v in ipairs({'Vanilla', 'TBC', 'Mainline'}) do
    it('loads ' .. v, function()
      assert.same('table', type(loader.loadFunctions(v, {}, nil, {})))
    end)
  end
end)
