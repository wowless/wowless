local addonName = ...
local CreateFrame = _G.CreateFrame

local function assertEquals(expected, actual)
  if expected ~= actual then
    error(string.format('want %s, got %s', tostring(expected), tostring(actual)), 2)
  end
end

local tests = {
  {
    name = 'xml evaluation order',
    env = {
      log = {},
    },
    init = function(env)
      local function log(fmt, ...)
        table.insert(env.log, string.format(fmt, ...))
      end
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
    end,
    fn = function(env)
      local expected = {
        'OnLoad(WowlessSimpleFrame,none)',
        'OnShow(WowlessSimpleFrame,none)',
        'OnLoad(WowlessAttributeFrame,none)',
        'OnShow(WowlessAttributeFrame,none)',
        'OnLoad(WowlessHiddenFrame,none)',
        'OnLoad(WowlessParentKid2,WowlessParent)',
        'OnShow(WowlessParentKid2,WowlessParent)',
        'OnLoad(WowlessParentKid1,WowlessParent)',
        'OnShow(WowlessParentKid1,WowlessParent)',
        'OnLoad(WowlessParent,none)',
        'OnShow(WowlessParent,none)',
        'OnLoad(WowlessKeyParent,none)',
        'OnShow(WowlessKeyParent,none)',
        'OnLoad(WowlessKeyParentKid1,WowlessKeyParent)',
        'OnShow(WowlessKeyParentKid1,WowlessKeyParent)',
        'OnLoad(WowlessKeyParentKid2,WowlessKeyParent)',
        'OnShow(WowlessKeyParentKid2,WowlessKeyParent)',
        'before WowlessLuaFrame',
        'OnLoad(WowlessLuaFrame,none)',
        'OnShow(WowlessLuaFrame,none)',
        'after WowlessLuaFrame',
      }
      table.insert(env.log, 'before WowlessLuaFrame')
      CreateFrame('Frame', 'WowlessLuaFrame', nil, 'WowlessLogger')
      table.insert(env.log, 'after WowlessLuaFrame')
      assert(table.concat(env.log, ',') == table.concat(expected, ','))
    end,
  },
  {
    name = 'button text',
    fn = function()
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
    end,
  },
  {
    name = 'frame kid order',
    fn = function()
      local f = CreateFrame('Frame')
      local g = CreateFrame('Frame')
      local h = CreateFrame('Frame')
      g:SetParent(f)
      h:SetParent(f)
      assert(f:GetNumChildren() == 2)
      assert(select(1, f:GetChildren()) == g)
      assert(select(2, f:GetChildren()) == h)
      g:SetParent(f)
      assert(select(1, f:GetChildren()) == g)
      assert(select(2, f:GetChildren()) == h)
    end,
  },
  {
    name = 'frame three kids order',
    fn = function()
      local f = CreateFrame('Frame')
      local g = CreateFrame('Frame', nil, f)
      local h = CreateFrame('Frame', nil, f)
      local i = CreateFrame('Frame', nil, f)
      assert(f:GetNumChildren() == 3)
      assert(select(1, f:GetChildren()) == g)
      assert(select(2, f:GetChildren()) == h)
      assert(select(3, f:GetChildren()) == i)
      h:SetParent(nil)
      assert(f:GetNumChildren() == 2)
      assert(select(1, f:GetChildren()) == g)
      assert(select(2, f:GetChildren()) == i)
      h:SetParent(f)
      assert(f:GetNumChildren() == 3)
      assert(select(1, f:GetChildren()) == g)
      assert(select(2, f:GetChildren()) == i)
      assert(select(3, f:GetChildren()) == h)
    end,
  },
  {
    name = 'format missing numbers',
    fn = function()
      assertEquals('0', _G.format('%d'))
    end,
  },
  {
    name = 'format nil numbers',
    fn = function()
      assertEquals('0', _G.format('%d', nil))
    end,
    pending = true,  -- TODO remove
  },
  {
    name = 'does not format missing strings',
    fn = function()
      assert(not pcall(function() _G.format('%s') end))
    end,
  },
  {
    name = 'does not format nil strings',
    fn = function()
      assert(not pcall(function() _G.format('%s', nil) end))
    end,
  },
  {
    name = 'format handles indexed substitution',
    fn = function()
      assertEquals(' 7   moo', _G.format('%2$2d %1$5s', 'moo', 7))
    end,
    pending = true,  -- TODO remove
  },
}

for _, test in ipairs(tests) do
  if test.init then
    test.init(test.env)
  end
end

do
  local frame = CreateFrame('Frame')
  frame:RegisterEvent('ADDON_LOADED')
  frame:SetScript('OnEvent', function(_, _, name)
    if name == addonName then
      for _, test in ipairs(tests) do
        if not test.pending then
          test.fn(test.env)
        end
      end
    end
  end)
end
