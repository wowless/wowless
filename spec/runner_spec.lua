describe('runner', function()
  it('loads required versions', function()
    local versions = {
      wow = 'Mainline',
      wow_classic = 'TBC',
      wow_classic_era = 'Vanilla',
      wow_classic_era_ptr = 'Vanilla',
      wow_classic_ptr = 'TBC',
    }
    local cmds = {'set -e ;'}
    for k, v in pairs(versions) do
      table.insert(cmds, string.format('bin/run.sh 0 %s %s &', k, v))
    end
    for _ = 2, #cmds do
      table.insert(cmds, 'wait -n ;')
    end
    local inner = string.format('bash -c "%s"', table.concat(cmds, ''))
    local outer = string.format('bash -c \'%s\' >/dev/null; echo $?', inner)
    local handle = io.popen(outer)
    local content = handle:read('*all')
    handle:close()
    assert.same('0\n', content)
  end)
end)
