local api = ...
return function(self, shown)
  local oldv = self.shown
  local newv = not not shown
  self.shown = newv
  if oldv ~= newv and (not self.parent or self.parent:IsVisible()) then
    api.UpdateVisible(self, newv)
  end
end
