describe('dblist', function()
  it('works', function()
    local f = require('tools.dblist')
    for _, p in ipairs(require('wowless.util').productList()) do
      assert.same('table', type(f(p)))
    end
  end)
end)
