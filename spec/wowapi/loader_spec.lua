describe('loader', function()
  local loader = require('wowapi.loader')

  for _, v in ipairs({'Vanilla', 'TBC', 'Mainline'}) do
    it('loads ' .. v, function()
      local api = { env = {}, states = {} }
      local wowlessLoader = { version = v }
      assert.same('table', type(loader.loadFunctions(api, wowlessLoader)))
    end)
  end
end)
