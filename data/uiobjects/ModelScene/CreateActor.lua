local api = ...
return function(self, name, template)
  return api.CreateChildUIObject('actor', self, name, template)
end
