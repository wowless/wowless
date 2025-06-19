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
      v[(b .. d):lower()] = true
    end
  end
  return v
end)()
return function(self, ...)
  table.wipe(self.registeredClicks)
  for i = 1, select('#', ...) do
    local clickType = select(i, ...)
    assert(type(clickType) == 'string', 'expected string, got ' .. type(clickType))
    local ltype = clickType:lower()
    assert(validValues[ltype], 'invalid click registration type ' .. clickType)
    self.registeredClicks[ltype] = true
  end
end
