describe('png', function()
  it('writes', function()
    local t = {}
    for i = 0, 255 do
      for j = 0, 255 do
        table.insert(t, string.char(0, i, 0, j))
      end
    end
    assert.same(
      require('pl.file').read('spec/wowless/green.png'),
      require('wowless.png').write(256, 256, table.concat(t))
    )
  end)
end)
