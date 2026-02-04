describe('addon', function()
  for _, product in ipairs(require('build.data.products')) do
    describe(product, function()
      it('runs', function()
        -- runtests.lua overwrites _G.assert, which confuses the addon.
        -- Restore it around runner runs.
        local tmpassert = _G.assert
        _G.assert = _G.oldassert
        local success, modules = pcall(function()
          return require('wowless.runner').run({
            otherAddonDirs = {
              'addon/Wowless/', -- trailing slash to validate fix for #235
              'build/cmake/products/' .. product .. '/WowlessData',
            },
            product = product,
          })
        end)
        _G.assert = tmpassert
        assert.True(success, modules)
        assert.True(modules.env.genv.WowlessTestsDone)
        assert.same({}, modules.env.genv.WowlessTestFailures)
        assert.same(0, modules.security.GetErrorCount())
      end)
    end)
  end
end)
