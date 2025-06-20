local api = ...
return function(self, type)
  local ltype = (type or 'animation'):lower()
  assert(api.InheritsFrom(ltype, 'animation'))
  return api.CreateUIObject(ltype, nil, self)
end
