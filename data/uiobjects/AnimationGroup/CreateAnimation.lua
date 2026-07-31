local api, uiobjecttypes = ...
return function(self, type, name, templateName)
  local ltype = (type or 'animation'):lower()
  if not (uiobjecttypes.Has(ltype) and uiobjecttypes.InheritsFrom(ltype, 'animation')) then
    ltype = 'animation'
  end
  return api.CreateChildUIObject(ltype, self, name, templateName)
end
