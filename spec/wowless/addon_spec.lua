describe('addon', function()
  for _, product in ipairs(require('build.data.products')) do
    describe(product, function()
      it('runs', function()
        local modules = require('wowless.runner').run({
          otherAddonDirs = {
            'addon/Wowless/', -- trailing slash to validate fix for #235
            'build/products/' .. product .. '/WowlessData',
          },
          product = product,
        })
        assert.True(modules.env.genv.WowlessTestsDone)
        assert.same({}, modules.env.genv.WowlessTestFailures)
        assert.same(0, modules.security.GetErrorCount())
      end)
    end)
  end
end)
