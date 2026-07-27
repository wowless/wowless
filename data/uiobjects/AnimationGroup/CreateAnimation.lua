local api, uiobjecttypes = ...
return function(self, type)
  local ltype = (type or 'animation'):lower()
  if not (uiobjecttypes.Has(ltype) and uiobjecttypes.InheritsFrom(ltype, 'animation')) then
    ltype = 'animation'
  end
  return api.CreateUIObject(ltype, nil, self)
end
