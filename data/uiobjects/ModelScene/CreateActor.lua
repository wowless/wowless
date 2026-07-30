local templates = ...
return function(self, name, template)
  local tmpls = template and { templates.GetTemplateOrThrow(template) }
  return templates.CreateUIObject('actor', name, self, nil, tmpls)
end
