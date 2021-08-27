describe('runner', function()
  local runner = require('wowless.runner')
  it('loads wow classic', function()
    local api = runner.run({
      dir = 'extracts/wow_classic/Interface',
      version = 'TBC',
    })
    assert.same(0, api.GetErrorCount())
  end)
  it('loads wow classic era', function()
    local api = runner.run({
      dir = 'extracts/wow_classic_era/Interface',
      version = 'Vanilla',
    })
    assert.same(0, api.GetErrorCount())
  end)
  it('loads wow classic ptr', function()
    local api = runner.run({
      dir = 'extracts/wow_classic_ptr/Interface',
      version = 'TBC',
    })
    assert.same(0, api.GetErrorCount())
  end)
end)
