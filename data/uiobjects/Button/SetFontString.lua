return (function(self, value)
  local ud = value and api.UserData(value)
  api.SetParent(ud, self)
  self.fontstring = ud
end)(...)
