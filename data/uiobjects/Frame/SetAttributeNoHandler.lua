return (function(self, name, value)
  api.log(4, 'setting attribute %s on %s to %s', name, tostring(self:GetName()), tostring(value))
  u(self).attributes[name] = value
end)(...)
