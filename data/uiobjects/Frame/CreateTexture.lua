local api = ...
return function(self, name, layer, inherits, sublevel)
  return api.CreateChildUIObject('texture', self, name, inherits, layer, sublevel)
end
