return (function(self, shown)
  local wasVisible = m(self, 'IsVisible')
  u(self).shown = not not shown
  local visibleNow = m(self, 'IsVisible')
  if wasVisible ~= visibleNow then
    UpdateVisible(self)
  end
end)(...)
