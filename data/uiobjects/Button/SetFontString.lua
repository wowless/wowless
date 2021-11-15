return (function(self, value)
  u(u(value).parent).fontstring = nil
  api.SetParent(value, self)
  u(self).fontstring = value
end)(...)
