local _, G = ...
_G.Wowless = G
_G.assertEquals = G.assertEquals

-- A real client only prefixes XML-parsing LUA_WARNINGs with a file:line
-- when this cvar is on (default). Forcing it off here -- which affects a
-- real client running this same addon too -- means neither side needs to
-- track/replicate the surprising rules for how that prefix gets built;
-- see issue #864.
_G.C_CVar.SetCVar('enableSourceLocationLookup', '0')

if _G.ScriptErrorsFrame then
  _G.ScriptErrorsFrame:UnregisterEvent('LUA_WARNING')
end
G.ActualLuaWarnings = {}
G.ExpectedLuaWarnings = {}
local frame = CreateFrame('Frame')
frame:RegisterEvent('LUA_WARNING')
frame:SetScript('OnEvent', function(_, _, warnText)
  table.insert(G.ActualLuaWarnings, warnText)
end)
G.LuaWarningsFrame = frame
G.testsuite = {}
