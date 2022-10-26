local api, name = ...
local t = api.templates[name:lower()]
if t then
  return {
    height = 0,
    inherits = t.inherits,
    type = t.type,
    width = 0,
  }
end
