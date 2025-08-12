local api, templates = ...
return function(self, name, layer, inherits, sublayer)
  -- TODO unify with api
  local tmpls = {}
  for templateName in string.gmatch(inherits or '', '[^, ]+') do
    table.insert(tmpls, templates.GetTemplateOrThrow(templateName))
  end
  local tex = api.CreateUIObject('texture', name, self, nil, tmpls)
  if layer then
    tex:SetDrawLayer(layer, sublayer)
  end
  return tex
end
