local api = ...
return function(self, name, templateName, order)
  local point = api.CreateChildUIObject('controlpoint', self, name, templateName)
  if order then
    point.order = order
  end
  return point
end
