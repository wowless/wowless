local _, G = ...
_G.assertEquals = G.assertEquals

if _G.UIParent then
  _G.UIParent:UnregisterEvent('LUA_WARNING')
end
G.LuaWarnings = {}
local frame = CreateFrame('Frame')
frame:RegisterEvent('LUA_WARNING')
frame:SetScript('OnEvent', function(_, _, warnType, warnText)
  table.insert(G.LuaWarnings, {
    warnText = warnText,
    warnType = warnType,
  })
end)
G.LuaWarningsFrame = frame
