describe('addon', function()
  for _, product in ipairs(require('build.data.products')) do
    describe(product, function()
      it('runs', function()
        -- runtests.lua overwrites _G.assert, which confuses the addon.
        -- Restore it around runner runs.
        local tmpassert = _G.assert
        _G.assert = _G.oldassert
        local success, result = pcall(function()
          return require('wowless.runner').run({
            otherAddonDirs = {
              'build/addon/Wowless/', -- trailing slash to validate fix for #235
              'build/products/' .. product .. '/WowlessData',
            },
            product = product,
          })
        end)
        _G.assert = tmpassert
        assert.True(success, result)
        assert.True(result.done)
        assert.same({}, result.failures)
        assert.same(0, result.errorCount)
      end)
    end)
  end
end)
