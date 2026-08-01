local api = ...
return function(self, name, templateName)
  return api.CreateChildUIObject('controlpoint', self, name, templateName)
end
