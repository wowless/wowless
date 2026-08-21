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

-- Mirrors wowless's own warningqueue/xmlwarningqueue split: every
-- LUA_WARNING is queued for next-frame delivery, none fire inline, so
-- that alone isn't a reason to track two buckets. The real distinction
-- is XML-time warnings (like anchor resolution or unrecognized
-- elements), which stage separately and only get dumped into the main
-- warning queue once a frame has passed, versus warnings from an
-- actual Lua call (CreateFrame, bindScript), which queue directly.
-- Tests for the former register into ExpectedXmlWarnings instead of
-- ExpectedLuaWarnings directly; a single After(0) call moves the whole
-- batch across at once, since ordering among multiple After(0)
-- callbacks isn't guaranteed.
G.ExpectedXmlWarnings = {}
_G.C_Timer.After(0, function()
  for _, v in ipairs(G.ExpectedXmlWarnings) do
    table.insert(G.ExpectedLuaWarnings, v)
  end
  table.wipe(G.ExpectedXmlWarnings)
end)
