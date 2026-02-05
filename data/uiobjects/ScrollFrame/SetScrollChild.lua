local api, points = ...
return function(self, scrollChild)
  local old = self.scrollChild
  if old then
    api.SetParent(old, nil)
  end
  self.scrollChild = scrollChild
  if scrollChild then
    api.SetParent(scrollChild, self)
    points.ClearAllPoints(scrollChild)
    points.SetPointInternal(scrollChild, 'TOPLEFT', self, 'TOPLEFT', 0, 0)
  end
end
