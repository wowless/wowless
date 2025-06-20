describe('impl', function()
  it('references exactly the files in data/impl, except for specials', function()
    local expected = {}
    for k, v in pairs(require('build.data.impl')) do
      expected['data/impl/' .. k .. '.lua'] = not v.module and not v.stdlib and not v.delegate or nil
    end
    local actual = {}
    for _, f in ipairs(require('pl.dir').getfiles('data/impl')) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
  it('references exactly the set of all implemented apis', function()
    local expected = {}
    for k in pairs(require('build.data.impl')) do
      expected[k] = true
    end
    local actual = {}
    for _, p in ipairs(require('build.data.products')) do
      for _, v in pairs(require('build.data.products.' .. p .. '.apis')) do
        if v.impl then
          actual[v.impl] = true
        end
      end
    end
    assert.same(expected, actual)
  end)
end)
