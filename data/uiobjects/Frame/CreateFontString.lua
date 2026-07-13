local api, templates = ...
return function(self, name, layer, inherits)
  local tmpls = {}
  for templateName in string.gmatch(inherits or '', '[^, ]+') do
    table.insert(tmpls, templates.GetTemplateOrThrow(templateName))
  end
  local fs = api.CreateUIObject('fontstring', type(name) == 'string' and name or nil, self, nil, tmpls)
  if layer then
    fs:SetDrawLayer(layer)
  end
  return fs
end
