local events = ...
return function()
  local taint = _G.THETAINT
  if taint then
    events.SendEvent('ADDON_ACTION_FORBIDDEN', taint, 'UNKNOWN()')
  end
end
