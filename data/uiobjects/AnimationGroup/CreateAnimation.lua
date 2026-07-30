local templates, uiobjecttypes = ...
return function(self, type)
  local ltype = (type or 'animation'):lower()
  if not (uiobjecttypes.Has(ltype) and uiobjecttypes.InheritsFrom(ltype, 'animation')) then
    ltype = 'animation'
  end
  return templates.CreateUIObject(ltype, nil, self)
end
