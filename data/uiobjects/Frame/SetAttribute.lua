local api = ...
return function(self, name, value)
  self.attributes[name] = value
  api.RunScript(self, 'OnAttributeChanged', name, value)
end
