describe('loader', function()
  local loader = require('wowless.loader')
  it('loads', function()
    local api = loader.run(0)
    assert.same(0, api.GetErrorCount())
    api.SendEvent('PLAYER_LOGIN')
    assert.same(0, api.GetErrorCount())
    api.SendEvent('PLAYER_ENTERING_WORLD')
    assert.same(0, api.GetErrorCount())
    for _, frame in ipairs(api.frames) do
      if frame.Click and frame:IsVisible() then
        frame:Click()
      end
    end
    assert.same(122, api.GetErrorCount())
  end)
end)
