describe('addon', function()
  for _, product in ipairs(require('build.data.products')) do
    describe(product, function()
      it('runs', function()
        local api = require('wowless.runner').run({
          otherAddonDirs = {
            'addon/Wowless/', -- trailing slash to validate fix for #235
            'build/products/' .. product .. '/WowlessData',
          },
          product = product,
        })
        assert.True(api.env.WowlessTestsDone)
        assert.same({}, api.env.WowlessTestFailures)
        assert.same(0, api.GetErrorCount())
      end)
    end)
  end
end)
