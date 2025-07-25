local api = ...
local IsVisible = api.IsVisible
return function(self, shown)
  local oldv = self.shown
  local newv = not not shown
  self.shown = newv
  if oldv ~= newv and IsVisible(self.parent) then
    api.UpdateVisible(self, newv)
  end
end
