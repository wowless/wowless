describe('tools.scrapelib', function()
  local function scrape(data)
    local tmp = os.tmpname()
    require('pl.file').write(tmp, 'TheFlatDumperData = ' .. require('pl.pretty').write(data))
    local ret = require('tools.scrapelib')(tmp)
    os.remove(tmp)
    return ret
  end
  it('handles empty data', function()
    assert.same({}, scrape({}))
  end)
  it('refs', function()
    local data = scrape({
      [1] = {
        sFoo = 't2',
        sBar = 't3',
      },
      [2] = {
        sBaz = 't4',
        sQuux = 'n42',
      },
      [3] = {},
      [4] = {
        sFrob = 'sMoo'
      },
    })
    assert.same('Moo', data:resolve(data:global('sFoo', 'sBaz', 'sFrob')))
    assert.same(42, data:resolve(data:global('sFoo', 'sQuux')))
    assert.same({}, data:resolve(data:global('sBar')))
  end)
end)