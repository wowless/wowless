local templates, xmleval = ...
return function(self, name, template)
  local tmpls = template and { templates.GetTemplateOrThrow(template) }
  return xmleval.CreateUIObject('actor', name, self, nil, tmpls)
end
