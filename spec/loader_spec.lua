describe('loader', function()
  local loader = require('wowless.loader')
  it('loads', function()
    local env = loader.run(0, true)
    local count = 0
    for _ in pairs(env) do
      count = count + 1
    end
    assert.same(13857, count)
  end)
end)
