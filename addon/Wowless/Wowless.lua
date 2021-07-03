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

do
  local function scriptHandler(name, self, ...)
    local rest = table.concat({...}, ',')
    log('%s(%s%s)', name, self:GetName(), rest ~= '' and (',' .. rest) or '')
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
end
