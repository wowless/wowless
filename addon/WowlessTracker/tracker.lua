local events = _G.WowlessData.Events
local frame = _G.CreateFrame('Frame')
frame:RegisterAllEvents()
frame:SetScript('OnEvent', function(_, ev)
  assert(events[ev], 'missing event ' .. ev)
end)
