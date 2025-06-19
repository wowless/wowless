local api = ...
return function(self, name, template)
  local tmpls = template and { api.templates[template:lower()] }
  return api.CreateUIObject('actor', name, self, nil, tmpls)
end
