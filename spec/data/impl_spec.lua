describe('impl', function()
  it('has the right files', function()
    local expected = {}
    for k in pairs(require('build/data/impl')) do
      expected['data/impl/' .. k .. '.lua'] = true
    end
    local actual = {}
    for _, f in ipairs(require('pl.dir').getfiles('data/impl')) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
end)
