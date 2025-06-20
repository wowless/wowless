return function(addon)
  local value = addon and addon.loaded or false
  -- TODO separate values for loaded and finished
  return value, value
end
