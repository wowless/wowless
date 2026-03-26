local T, CreateFrame, MoveAndSteerStart = ...
local args
local f = CreateFrame('Frame')
f:RegisterEvent('ADDON_ACTION_FORBIDDEN')
f:SetScript('OnEvent', function(_, _, ...)
  args = { ... }
end)
T.check1(true, pcall(MoveAndSteerStart))
T.assertEquals(2, #args)
T.assertEquals(T.addonName, args[1])
T.assertEquals('UNKNOWN()', args[2])
