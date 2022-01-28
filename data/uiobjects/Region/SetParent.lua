return (function(self, parent)
  if type(parent) == 'string' then
    parent = api.env[parent]
  end
  local wasVisible = m(self, 'IsVisible')
  api.SetParent(self, parent)
  local visibleNow = m(self, 'IsVisible')
  if wasVisible ~= visibleNow then
    UpdateVisible(self)
  end
end)(...)
