-- These represent real gaps between wowless's taint semantics and elune's;
-- follow-up work should shrink this set, not grow it.
local expectedScriptcaseFailures = {
  ['OP_GETGLOBAL: Read from insecure function environment'] = true,
  ['getfenv: Read tainted environment'] = true,
  ['seterrorhandler: replaces \'*\' source with object names'] = true,
}

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
              'build/addon/Wowless/', -- trailing slash to validate fix for #235
              'build/products/' .. product .. '/WowlessData',
            },
            product = product,
          })
        end)
        _G.assert = tmpassert
        assert.True(success, modules)
        assert.True(modules.env.genv.WowlessTestsDone)
        assert.same({}, modules.env.genv.WowlessTestFailures)
        assert.same(0, modules.errors.GetErrorCount())
      end)
      it('runs elune scriptcases', function()
        local tmpassert = _G.assert
        _G.assert = _G.oldassert
        local success, modules = pcall(function()
          return require('wowless.runner').run({
            signedAddonDirs = {
              'build/eluneaddon/EluneTest/',
            },
            product = product,
          })
        end)
        _G.assert = tmpassert
        assert.True(success, modules)
        local actualFailures = {}
        for name in pairs(modules.env.genv.EluneScriptcaseFailures) do
          actualFailures[name] = true
        end
        assert.same(expectedScriptcaseFailures, actualFailures)
      end)
    end)
  end
end)
