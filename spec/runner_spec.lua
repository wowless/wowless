describe('runner', function()
  local versions = {
    wow_classic = 'TBC',
    wow_classic_era = 'Vanilla',
    wow_classic_era_ptr = 'Vanilla',
    wow_classic_ptr = 'TBC',
  }
  local runner = require('wowless.runner')
  for k, v in pairs(versions) do
    it('loads ' .. k, function()
      local api = runner.run({
        dir = 'extracts/' .. k .. '/Interface',
        version = v
      })
      assert.same(0, api.GetErrorCount())
    end)
  end
end)
