return (function(self, ...)
  assert(select('#', ...) == 1, 'SetScrollChild: wrong number of arguments')
  local scrollChild = ...
  assert(
    type(scrollChild) == 'table' or api.datalua.build.flavor == 'Vanilla',
    'Usage: self:SetScrollChild(scrollChild)'
  )
  if type(scrollChild) == 'string' then
    scrollChild = api.env[scrollChild]
  end
  local old = self.scrollChild
  if old then
    old:SetParent(nil)
  end
  self.scrollChild = scrollChild and u(scrollChild)
  if self.scrollChild then
    api.SetParent(self.scrollChild, self)
  end
end)(...)
