local api = ...
return function(self, name, layer, inherits, sublevel)
  return api.CreateChildUIObject('line', self, name, inherits, layer, sublevel)
end
