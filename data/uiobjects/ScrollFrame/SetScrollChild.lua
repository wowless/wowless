return (function(self, ...)
  assert(select('#', ...) == 1, 'SetScrollChild: wrong number of arguments')
  local scrollChild = ...
  assert(type(scrollChild) == 'table' or build.flavor == 'Vanilla', 'Usage: self:SetScrollChild(scrollChild)')
  if type(scrollChild) == 'string' then
    scrollChild = api.env[scrollChild]
  end
  local old = u(self).scrollChild
  if old then
    old:SetParent(nil)
  end
  u(self).scrollChild = scrollChild
  if scrollChild then
    scrollChild:SetParent(self)
  end
end)(...)
