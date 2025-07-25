local api = ...
local IsVisible = api.IsVisible
return function(self)
  return self.shown and IsVisible(self.parent)
end
