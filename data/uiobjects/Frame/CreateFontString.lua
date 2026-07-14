local api = ...
return function(self, name, layer, inherits)
  return api.CreateChildUIObject('fontstring', self, type(name) == 'string' and name or nil, inherits, layer)
end
