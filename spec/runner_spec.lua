describe('runner', function()
  it('loads required versions', function()
    local versions = {
      wow = 'Mainline',
      wowt = 'Mainline',
      wow_classic = 'TBC',
      wow_classic_era = 'Vanilla',
      wow_classic_era_ptr = 'Vanilla',
      wow_classic_ptr = 'TBC',
    }
    local handles = {}
    for k, v in pairs(versions) do
      handles[k] = io.popen(string.format('bin/run.sh 0 %s %s 2>&1', k, v))
    end
    local results = {}
    for k, h in pairs(handles) do
      results[k] = h:read('*all')
      h:close()
    end
    local expected = {}
    for k in pairs(versions) do
      expected[k] = ''
    end
    assert.same(expected, results)
  end)
end)
