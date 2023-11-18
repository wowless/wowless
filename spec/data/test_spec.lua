describe('test', function()
  it('references exactly the files in data/test', function()
    local expected = {}
    for k in pairs(require('build.data.test')) do
      expected['data/test/' .. k .. '.lua'] = true
    end
    local actual = {}
    for _, f in ipairs(require('pl.dir').getfiles('data/test')) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
end)
