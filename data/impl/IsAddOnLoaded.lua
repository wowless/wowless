local addon = ...
local value = addon and addon.loaded or false
-- TODO separate values for loaded and finished
return value, value
