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
    local env, errors = loader.run(0)
    assert.same({38345, 9}, {count(env), #errors})
  end)
end)
