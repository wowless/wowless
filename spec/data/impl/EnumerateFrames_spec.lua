describe('EnumerateFrames', function()
  local api = require('wowless.api').new(function() end, 0, 'wow')
  local loader = require('wowless.loader').loader(api, { product = 'wow' })
  require('wowless.env').init(api, loader)
  local impl = api.impls.EnumerateFrames
  local function collect()
    local t = {}
    local f = impl()
    while f ~= nil do
      table.insert(t, f)
      f = impl(f)
    end
    return t
  end
  it('works', function()
    assert.same({}, collect())
    local f1 = api.impls.CreateFrame('frame')
    assert.same({ f1 }, collect())
    local f2 = api.impls.CreateFrame('frame')
    assert.same({ f1, f2 }, collect())
    local f3 = api.impls.CreateFrame('frame')
    assert.same({ f1, f2, f3 }, collect())
  end)
end)
