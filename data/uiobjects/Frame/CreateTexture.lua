local api = ...
return function(self, name, layer, inherits, sublayer)
  -- TODO unify with api
  local tmpls = {}
  for templateName in string.gmatch(inherits or '', '[^, ]+') do
    local template = api.templates[string.lower(templateName)]
    assert(template, 'unknown template ' .. templateName)
    table.insert(tmpls, template)
  end
  local tex = api.CreateUIObject('texture', name, self, nil, tmpls)
  if layer then
    tex:SetDrawLayer(layer, sublayer)
  end
  return tex
end
