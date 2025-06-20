describe('sql', function()
  it('references exactly the files in data/sql', function()
    local expected = {}
    for k in pairs(require('build.data.sql')) do
      expected['data/sql/' .. k .. '.sql'] = true
    end
    local actual = {}
    for _, f in ipairs(require('pl.dir').getfiles('data/sql')) do
      actual[f] = true
    end
    assert.same(expected, actual)
  end)
  it('are all referenced by some impl', function()
    local expected = {}
    for k in pairs(require('build.data.sql')) do
      expected[k] = true
    end
    local actual = {}
    for _, v in pairs(require('build.data.impl')) do
      for _, sql in ipairs(v.sqls or { v.directsql }) do
        actual[sql] = true
      end
    end
    assert.same(expected, actual)
  end)
end)
