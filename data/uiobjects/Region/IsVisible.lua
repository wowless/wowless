return function(self)
  local p = self.parent
  return self.shown and (not p or p:IsVisible())
end
