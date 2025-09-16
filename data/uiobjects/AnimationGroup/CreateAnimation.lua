local api, uiobjecttypes = ...
return function(self, type)
  local ltype = (type or 'animation'):lower()
  assert(uiobjecttypes.InheritsFrom(ltype, 'animation'))
  return api.CreateUIObject(ltype, nil, self)
end
