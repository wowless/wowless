local api = ...
return function(self, name)
  return api.CreateUIObject('fontstring', type(name) == 'string' and name or nil, self)
end
