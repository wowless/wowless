describe('loader', function()
  local loader = require('wowapi.loader')

  for _, p in ipairs(require('wowless.util').productList()) do
    it('loads ' .. p, function()
      local api = { env = {}, states = {} }
      local wowlessLoader = {
        product = p,
        sqlitedb = require('wowapi.sqlite')(p)(),
      }
      assert.same('table', type(loader.loadFunctions(api, wowlessLoader)))
    end)
  end
end)
