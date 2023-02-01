return (function(self, name, value)
  u(self).attributes[name] = value
  api.RunScript(u(self), 'OnAttributeChanged', name, value)
end)(...)
