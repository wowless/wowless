return (function(self, value)
  local ud = value and u(value)
  api.SetParent(ud, self)
  self.fontstring = ud
end)(...)
