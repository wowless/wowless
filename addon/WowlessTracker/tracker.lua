local events = _G.WowlessData.Events
local frame = _G.CreateFrame('Frame')
frame:RegisterAllEvents()
frame:SetScript('OnEvent', function(_, ev, ...)
  local e = events[ev]
  assert(e, 'missing event ' .. ev)
  local n = select('#', ...)
  assert(e.payload == n, 'wrong number of args for ' .. ev .. ', got ' .. n)
end)
