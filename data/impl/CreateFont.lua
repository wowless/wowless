local templates = ...
local cache = {}
return function(name)
  local font = cache[name]
  if not font then
    font = templates.CreateUIObject('font', name)
    cache[name] = font
  end
  return font
end
