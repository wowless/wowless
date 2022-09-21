local product = 'wow'
local api = require('wowless.api').new(function() end, nil, product)
local loader = require('wowless.loader').loader(api, { product = product })
require('wowless.env').init(api, loader)

describe('frame', function()
  it('has expected defaults', function()
    local f = api.impls.CreateFrame('frame')
    local expected = {
      height = 0,
      numPoints = 0,
      object = { [0] = f[0] },
      shown = true,
      size = { 0, 0 },
      type = 'Frame',
      visible = true,
      width = 0,
    }
    local actual = {
      height = f:GetHeight(),
      name = f:GetName(),
      numPoints = f:GetNumPoints(),
      object = f,
      parent = f:GetParent(),
      shown = f:IsShown(),
      size = { f:GetSize() },
      type = f:GetObjectType(),
      visible = f:IsVisible(),
      width = f:GetWidth(),
    }
    assert.same(expected, actual)
  end)

  it('is added to global environment if named', function()
    local f = api.impls.CreateFrame('frame', 'sillyName')
    assert.equals(f, api.env.sillyName)
  end)

  it('maintains kid order', function()
    local f = api.impls.CreateFrame('frame')
    assert.same(0, f:GetNumChildren())
    local g = api.impls.CreateFrame('frame', nil, f)
    assert.same(1, f:GetNumChildren())
    do
      (function(...)
        assert.same(1, select('#', ...))
        assert.equals(g, select(1, ...))
      end)(f:GetChildren())
    end
    local h = api.impls.CreateFrame('frame', nil, f)
    assert.same(2, f:GetNumChildren())
    do
      (function(...)
        assert.same(2, select('#', ...))
        assert.equals(g, select(1, ...))
        assert.equals(h, select(2, ...))
      end)(f:GetChildren())
    end
    g:SetParent(api.impls.CreateFrame('frame'))
    assert.same(1, f:GetNumChildren())
    do
      (function(...)
        assert.same(1, select('#', ...))
        assert.equals(h, select(1, ...))
      end)(f:GetChildren())
    end
  end)

  it('handles show/hide with no parent and no kids', function()
    local f = api.impls.CreateFrame('frame')
    assert.True(f:IsShown())
    assert.True(f:IsVisible())
    f:Show()
    assert.True(f:IsShown())
    assert.True(f:IsVisible())
    f:Hide()
    assert.False(f:IsShown())
    assert.False(f:IsVisible())
    f:Hide()
    assert.False(f:IsShown())
    assert.False(f:IsVisible())
    f:Show()
    assert.True(f:IsShown())
    assert.True(f:IsVisible())
  end)

  it('handles show/hide across three generations', function()
    local a = api.impls.CreateFrame('frame')
    local b = api.impls.CreateFrame('frame', nil, a)
    local c = api.impls.CreateFrame('frame', nil, b)
    local function state()
      return { a:IsShown(), a:IsVisible(), b:IsShown(), b:IsVisible(), c:IsShown(), c:IsVisible() }
    end
    assert.same({ true, true, true, true, true, true }, state())
    b:Hide()
    assert.same({ true, true, false, false, true, false }, state())
    c:Show()
    assert.same({ true, true, false, false, true, false }, state())
    c:Hide()
    assert.same({ true, true, false, false, false, false }, state())
    a:Show()
    assert.same({ true, true, false, false, false, false }, state())
    b:Show()
    assert.same({ true, true, true, true, false, false }, state())
    c:Show()
    assert.same({ true, true, true, true, true, true }, state())
    a:Hide()
    assert.same({ false, false, true, false, true, false }, state())
  end)

  it('does not overflow the stack when OnShow/OnHide call themselves', function()
    local f = api.impls.CreateFrame('frame')
    f:SetScript('OnShow', function(self)
      self:Show()
    end)
    f:SetScript('OnHide', function(self)
      self:Hide()
    end)
    f:Hide()
    f:Show()
    assert.same(0, api.GetErrorCount())
  end)

  it('overflows the stack when OnShow/OnHide call each other', function()
    local f = api.impls.CreateFrame('frame')
    f:SetScript('OnShow', function(self)
      self:Hide()
    end)
    f:SetScript('OnHide', function(self)
      self:Show()
    end)
    f:Hide()
    assert.Not.same(0, api.GetErrorCount())
  end)

  it('shares metatables across instances', function()
    local f = api.impls.CreateFrame('frame')
    local g = api.impls.CreateFrame('frame')
    assert.Not.equals(f, g)
    assert.equals(getmetatable(f), getmetatable(g))
  end)

  it('gets a new method when hooked', function()
    local f = api.impls.CreateFrame('frame')
    api.env.hooksecurefunc(f, 'Show', function() end)
    assert.Not.same(f.Show, getmetatable(f).__index.Show)
  end)

  it('gets a new script handler when hooked', function()
    local f = api.impls.CreateFrame('frame')
    f:SetScript('OnShow', function() end)
    local h = f:GetScript('OnShow')
    assert.True(f:HookScript('OnShow', function() end))
    assert.Not.equal(h, f:GetScript('OnShow'))
  end)

  it('has a metatable containing only a mutable __index table', function()
    local f = api.impls.CreateFrame('frame', 'moo')
    local m = getmetatable(f)
    local k, v = next(m)
    assert.same('__index', k)
    assert.same('table', type(v))
    assert.Nil(next(m, k))
    v.rofl = function(self, arg)
      return 'rofl ' .. self:GetName() .. ' ' .. arg
    end
    assert.same('rofl moo copter', f:rofl('copter'))
  end)

  it('support $parent in frame names', function()
    api.impls.CreateFrame('frame', 'Moo')
    local mooCow = api.impls.CreateFrame('frame', '$parentCow', api.env.Moo)
    local topCow = api.impls.CreateFrame('frame', '$parentCow')
    assert.equals(mooCow, api.env.MooCow)
    assert.same('MooCow', mooCow:GetName())
    assert.equals(topCow, api.env.TopCow)
    assert.same('TopCow', topCow:GetName())
  end)
end)
