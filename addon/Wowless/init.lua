local _, G = ...
_G.Wowless = G
_G.assertEquals = G.assertEquals

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

-- Mirrors QueueEvent/DrainEvents: some LUA_WARNINGs (XML-time issues
-- like anchor resolution or unrecognized elements) are queued and only
-- delivered at the start of the next frame, not fired inline. Tests for
-- those register into ExpectedNextFrame instead of ExpectedLuaWarnings
-- directly; a single After(0) call moves the whole batch across at
-- once, since ordering among multiple After(0) callbacks isn't
-- guaranteed.
G.ExpectedNextFrame = {}
_G.C_Timer.After(0, function()
  for _, v in ipairs(G.ExpectedNextFrame) do
    table.insert(G.ExpectedLuaWarnings, v)
  end
  table.wipe(G.ExpectedNextFrame)
end)
