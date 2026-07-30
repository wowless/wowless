local uiobjects = ...
return function(self, value)
  uiobjects.SetParent(value, self)
  self.fontstring = value
end
