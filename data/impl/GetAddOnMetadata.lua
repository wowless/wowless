local addon, field = ...
local v = addon and addon.attrs[field]
if v then
  return v
end
