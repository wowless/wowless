local log = (function()
  local theLog = {}
  do
    local frame = _G.CreateFrame('Frame')
    frame:RegisterEvent('PLAYER_LOGOUT')
    frame:SetScript('OnEvent', function()
      _G.WowlessLog = theLog
    end)
  end
  return function(fmt, ...)
    table.insert(theLog, string.format(fmt, ...))
  end
end)()

local function WowlessAttributeFrame_OnLoad()
  log('OnLoad')
end

local function WowlessAttributeFrame_OnAttributeChanged(_, name, value)
  log('OnAttributeChanged(%s,%s)', name, value)
end

_G.Mixin(_G, {
  WowlessAttributeFrame_OnLoad = WowlessAttributeFrame_OnLoad,
  WowlessAttributeFrame_OnAttributeChanged = WowlessAttributeFrame_OnAttributeChanged,
})
