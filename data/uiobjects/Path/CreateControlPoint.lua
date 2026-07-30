local templates = ...
return function(self, name)
  return templates.CreateUIObject('controlpoint', name, self)
end
