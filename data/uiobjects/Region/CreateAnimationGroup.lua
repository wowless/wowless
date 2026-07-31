local api = ...
return function(self, name, templateName)
  return api.CreateChildUIObject('animationgroup', self, name, templateName)
end
