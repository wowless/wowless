expose('addon', function()
  local versions = {
    'Vanilla',
    'TBC',
    'Mainline',
  }
  for _, version in ipairs(versions) do
    describe(version, function()
      it('runs', function()
        local api = require('wowless.runner').run({
          otherAddonDirs = { 'addon/Wowless' },
          version = version,
        })
        assert.same(0, api.GetErrorCount())
      end)
    end)
  end
end)
