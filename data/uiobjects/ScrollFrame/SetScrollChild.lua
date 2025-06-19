local api = ...
return function(self, scrollChild)
  local old = self.scrollChild
  if old then
    api.SetParent(old, nil)
  end
  self.scrollChild = scrollChild
  if self.scrollChild then
    api.SetParent(self.scrollChild, self)
  end
end
