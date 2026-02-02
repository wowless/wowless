local scripts = ...
return function(self, name, value)
  self.attributes[name] = value
  scripts.RunScript(self, 'OnAttributeChanged', name, value)
end
