local validValues = (function()
  local buttons = {
    'Any',
    'LeftButton',
    'RightButton',
    'MiddleButton',
    'Button4',
    'Button5',
  }
  local directions = { 'Up', 'Down' }
  local v = {}
  for _, b in ipairs(buttons) do
    for _, d in ipairs(directions) do
      v[b .. d] = true
    end
  end
  return v
end)()
return (function(self, ...)
  local ud = u(self)
  util.twipe(ud.registeredClicks)
  for i = 1, select('#', ...) do
    local type = select(i, ...)
    assert(validValues[type], 'invalid click registration type')
    ud.registeredClicks[type] = true
  end
end)(...)
