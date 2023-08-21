describe('addon', function()
  for _, product in ipairs(require('wowless.util').productList()) do
    describe(product, function()
      it('runs', function()
        local api = require('wowless.runner').run({
          otherAddonDirs = {
            'addon/Wowless',
            'build/products/' .. product .. '/WowlessData',
          },
          product = product,
        })
        assert.True(api.env.WowlessTestsDone)
        assert:set_parameter('TableFormatLevel', -1)
        assert.same({}, api.env.WowlessTestFailures)
        assert.same(0, api.GetErrorCount())
      end)
    end)
  end
end)
