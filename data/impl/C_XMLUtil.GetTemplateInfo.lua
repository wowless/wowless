local api, name = ...
local t = api.templates[name:lower()]
if t then
  return {
    height = 1,
    inherits = t.inherits and table.concat(t.inherits, ','),
    keyValues = {},
    sourceLocation = api.datalua.product == 'wowxptr' and 'source' or nil,
    type = t.type,
    width = 1,
  }
end
