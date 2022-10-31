local api, name = ...
local t = api.templates[name:lower()]
if t then
  return {
    height = 1,
    inherits = t.inherits,
    type = t.type,
    width = 1,
  }
end
