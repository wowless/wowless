describe('loader', function()
  local function count(t)
    local n = 0
    for _ in pairs(t) do
      n = n + 1
    end
    return n
  end
  local loader = require('wowless.loader')
  it('loads', function()
    local env, errors = loader.run(0, true)
    assert.same(13859, count(env))
    assert.same(0, #errors)
  end)
  it('loads errors', function()
    local env, errors = loader.run(0, false)
    assert.same(17282, count(env))
    assert.same(290, #errors)
  end)
end)
