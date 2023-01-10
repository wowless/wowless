return (function(self, name, value)
  u(self).attributes[name] = value
  api.RunScript(self, 'OnAttributeChanged', name, value)
end)(...)
