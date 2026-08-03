local points, uiobjects = ...
return function(self, scrollChild)
  local old = self.scrollChild
  if old then
    uiobjects.SetParent(old, nil)
  end
  self.scrollChild = scrollChild
  if scrollChild then
    uiobjects.SetParent(scrollChild, self)
    points.ClearAllPoints(scrollChild)
    points.SetPointInternal(scrollChild, 'TOPLEFT', self, 'TOPLEFT', 0, 0)
  end
end
