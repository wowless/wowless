local api = ...
return function(self, name)
  return api.CreateUIObject('controlpoint', name, self)
end
