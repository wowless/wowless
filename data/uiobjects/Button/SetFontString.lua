local api = ...
return function(self, value)
  api.SetParent(value, self)
  self.fontstring = value
end
