local api = ...
local cache = {}
return function(name)
  local font = cache[name]
  if not font then
    font = api.CreateUIObject('font', name)
    cache[name] = font
  end
  return font
end
