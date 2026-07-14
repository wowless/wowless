local api = ...
return function(self, name, layer, inherits, sublevel)
  return api.CreateChildUIObject('masktexture', self, name, inherits, layer, sublevel)
end
