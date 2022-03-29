describe('png', function()
  it('writes', function()
    local t = {}
    for i = 0, 255 do
      for j = 0, 255 do
        table.insert(t, string.char(0, i, 0, j))
      end
    end
    local tmp = os.tmpname()
    require('wowless.png').write(tmp, 256, 256, table.concat(t, ''))
    local readfile = require('pl.file').read
    assert.same(readfile('spec/wowless/green.png'), readfile(tmp))
  end)
end)
