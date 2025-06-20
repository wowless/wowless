describe('gametypes', function()
  it('are all referenced by some product', function()
    local expected = {}
    for k in pairs(require('build.data.gametypes')) do
      expected[k] = true
    end
    local actual = {}
    for _, p in ipairs(require('build.data.products')) do
      actual[require('build.data.products.' .. p .. '.build').gametype] = true
    end
    assert.same(expected, actual)
  end)
end)
