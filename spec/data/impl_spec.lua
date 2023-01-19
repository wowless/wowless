describe('impl', function()
  it('has the right files', function()
    local expected = {}
    for _, p in ipairs(require('wowless.util').productList()) do
      for _, v in pairs(require('wowapi.yaml').parseFile('data/products/' .. p .. '/apis.yaml')) do
        if v.impl then
          expected['data/impl/' .. v.impl .. '.lua'] = true
        end
      end
    end
    local actual = {}
    for _, f in ipairs(require('pl.dir').getfiles('data/impl')) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
end)
