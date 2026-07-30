local api, templates = ...
return function(self, name, template)
  local tmpls = template and { templates.GetTemplateOrThrow(template) }
  return api.CreateUIObject('actor', name, self, nil, tmpls)
end
