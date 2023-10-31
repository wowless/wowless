local _, G = ...
_G.Wowless = G
_G.assertEquals = G.assertEquals

if _G.UIParent then
  _G.UIParent:UnregisterEvent('LUA_WARNING')
end
G.ActualLuaWarnings = {}
G.ExpectedLuaWarnings = {}
local frame = CreateFrame('Frame')
frame:RegisterEvent('LUA_WARNING')
frame:SetScript('OnEvent', function(_, _, warnType, warnText)
  table.insert(G.ActualLuaWarnings, {
    warnText = warnText,
    warnType = warnType,
  })
end)
G.LuaWarningsFrame = frame
G.testsuite = {}
