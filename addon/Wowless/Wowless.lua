---@diagnostic disable-next-line: undefined-field
local CreateFrame = _G.CreateFrame

local log = (function()
  local theLog = {}
  do
    local frame = CreateFrame('Frame')
    frame:RegisterEvent('PLAYER_LOGOUT')
    frame:SetScript('OnEvent', function()
      _G.WowlessLog = theLog
    end)
  end
  return function(fmt, ...)
    table.insert(theLog, string.format(fmt, ...))
  end
end)()

do
  local function scriptHandler(name, self, ...)
    local rest = table.concat({...}, ',')
    local argstr = table.concat({
      self:GetName(),
      self:GetParent() and tostring(self:GetParent():GetName()) or 'none',
      rest ~= '' and rest or nil,
    }, ',')
    log('%s(%s)', name, argstr)
  end
  local names = {
    'OnAttributeChanged',
    'OnHide',
    'OnLoad',
    'OnShow',
  }
  for _, name in ipairs(names) do
    _G['Wowless_' .. name] = function(...)
      scriptHandler(name, ...)
    end
  end
end

do
  local frame = CreateFrame('Frame')
  frame:RegisterEvent('PLAYER_LOGIN')
  frame:SetScript('OnEvent', function()
    log('before WowlessLuaFrame')
    CreateFrame('Frame', 'WowlessLuaFrame', nil, 'WowlessLogger')
    log('after WowlessLuaFrame')
  end)
end

do
  local f = CreateFrame('Button')
  assert(f:GetNumRegions() == 0)
  assert(f:GetFontString() == nil)
  f:SetText('Moo')
  assert(f:GetNumRegions() == 1)
  local fs = f:GetFontString()
  assert(fs ~= nil)
  assert(f:GetRegions() == fs)
  assert(fs:GetParent() == f)
  assert(f:GetText() == 'Moo')
  assert(fs:GetText() == 'Moo')
  local g = CreateFrame('Button')
  assert(g:GetText() == nil)
  g:SetFontString(fs)
  assert(g:GetText() == 'Moo')
  assert(g:GetRegions() == fs)
  assert(fs:GetParent() == g)
  assert(f:GetText() == nil)
  assert(f:GetNumRegions() == 0)
  fs:SetParent(f)
  assert(fs:GetParent() == f)
  assert(f:GetNumRegions() == 1)
  assert(f:GetText() == nil)
  assert(f:GetFontString() == nil)
  assert(g:GetNumRegions() == 0)
  assert(g:GetText() == nil)
  assert(g:GetFontString() == nil)
end

-- TODO uncomment when this is working
--[[
do
  local f = CreateFrame('Frame')
  local g = CreateFrame('Frame', nil, f)
  local h = CreateFrame('Frame', nil, f)
  local i = CreateFrame('Frame', nil, f)
  assert(f:GetNumChildren() == 3)
  assert(select(1, f:GetChildren()) == g)
  assert(select(2, f:GetChildren()) == h)
  assert(select(3, f:GetChildren()) == i)
  h:SetParent(_G.UIParent)
  assert(f:GetNumChildren() == 2)
  assert(select(1, f:GetChildren()) == g)
  assert(select(2, f:GetChildren()) == i)
  h:SetParent(f)
  assert(f:GetNumChildren() == 3)
  assert(select(1, f:GetChildren()) == g)
  assert(select(2, f:GetChildren()) == i)
  assert(select(3, f:GetChildren()) == h)
end
]]--
