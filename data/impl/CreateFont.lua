local xmleval = ...
local cache = {}
return function(name)
  local font = cache[name]
  if not font then
    font = xmleval.CreateUIObject('font', name)
    cache[name] = font
  end
  return font
end
