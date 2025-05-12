describe('families', function()
  it('are all referenced by some gametype', function()
    local expected = {}
    for k in pairs(require('build.data.families')) do
      expected[k] = true
    end
    local actual = {}
    for _, v in pairs(require('build.data.gametypes')) do
      actual[v.family] = true
    end
    assert.same(expected, actual)
  end)
end)
