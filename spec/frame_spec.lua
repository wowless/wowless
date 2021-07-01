local api = require('wowless.api').new(function() end)
require('wowless.env').init(api)

describe('frame #small', function()
  it('has expected defaults', function()
    local f = api.env.CreateFrame('frame')
    local expected = {
      height = 0,
      numPoints = 0,
      shown = true,
      size = {0, 0},
      type = 'Frame',
      visible = true,
      width = 0,
    }
    local actual = {
      height = f:GetHeight(),
      name = f:GetName(),
      numPoints = f:GetNumPoints(),
      parent = f:GetParent(),
      shown = f:IsShown(),
      size = {f:GetSize()},
      type = f:GetObjectType(),
      visible = f:IsVisible(),
      width = f:GetWidth(),
    }
    assert.same(expected, actual)
  end)

  it('is added to global environment if named', function()
    local f = api.env.CreateFrame('frame', 'sillyName')
    assert.equals(f, api.env.sillyName)
  end)

  it('handles show/hide with no parent and no kids', function()
    local f = api.env.CreateFrame('frame')
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
    local a = api.env.CreateFrame('frame')
    local b = api.env.CreateFrame('frame', nil, a)
    local c = api.env.CreateFrame('frame', nil, b)
    local function state()
      return {a:IsShown(), a:IsVisible(), b:IsShown(), b:IsVisible(), c:IsShown(), c:IsVisible()}
    end
    assert.same({true, true, true, true, true, true}, state())
    b:Hide()
    assert.same({true, true, false, false, true, false}, state())
    c:Show()
    assert.same({true, true, false, false, true, false}, state())
    c:Hide()
    assert.same({true, true, false, false, false, false}, state())
    a:Show()
    assert.same({true, true, false, false, false, false}, state())
    b:Show()
    assert.same({true, true, true, true, false, false}, state())
    c:Show()
    assert.same({true, true, true, true, true, true}, state())
    a:Hide()
    assert.same({false, false, true, false, true, false}, state())
  end)

  it('does not overflow the stack when OnShow/OnHide call themselves', function()
    local f = api.env.CreateFrame('frame')
    f:SetScript('OnShow', function(self) self:Show() end)
    f:SetScript('OnHide', function(self) self:Hide() end)
    f:Hide()
    f:Show()
    assert.same(0, api.GetErrorCount())
  end)

  it('overflows the stack when OnShow/OnHide call each other', function()
    local f = api.env.CreateFrame('frame')
    f:SetScript('OnShow', function(self) self:Hide() end)
    f:SetScript('OnHide', function(self) self:Show() end)
    f:Hide()
    assert.Not.same(0, api.GetErrorCount())
  end)

  pending('shares metatables across instances', function()
    local f = api.env.CreateFrame('frame')
    local g = api.env.CreateFrame('frame')
    assert.Not.same(f, g)
    assert.same(getmetatable(f), getmetatable(g))
  end)
end)
