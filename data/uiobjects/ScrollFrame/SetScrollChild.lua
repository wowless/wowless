return (function(self, ...)
  assert(select('#', ...) == 1, 'SetScrollChild: wrong number of arguments')
  local scrollChild = ...
  if type(scrollChild) == 'string' then
    scrollChild = api.env[scrollChild]
  end
  u(self).scrollChild = scrollChild
  if scrollChild then
    scrollChild:SetParent(self)
  end
end)(...)