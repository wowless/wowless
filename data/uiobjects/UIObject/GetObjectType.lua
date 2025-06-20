local api = ...
return function(self)
  return api.uiobjectTypes[self.type].name
end
