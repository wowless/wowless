return (function(self, ...)
  assert(select('#', ...) == 1, 'SetScrollChild: wrong number of arguments')
  local scrollChild = ...
  assert(type(scrollChild) == 'table', 'Usage: self:SetScrollChild(scrollChild)')
  if type(scrollChild) == 'string' then
    scrollChild = api.env[scrollChild]
  end
  local old = self.scrollChild
  if old then
    api.SetParent(old, nil)
  end
  self.scrollChild = scrollChild and api.UserData(scrollChild)
  if self.scrollChild then
    api.SetParent(self.scrollChild, self)
  end
end)(...)
