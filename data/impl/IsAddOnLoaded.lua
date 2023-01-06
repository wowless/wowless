return (function(addons, addonIndexOrName)
  if type(addonIndexOrName) == 'string' then
    addonIndexOrName = addonIndexOrName:lower()
  end
  local addon = addons[addonIndexOrName]
  if tonumber(addonIndexOrName) and not addon then
    error('AddOn index must be in the range of 1 to ' .. #addons)
  else
    local value = addon and addon.loaded or false
    -- TODO separate values for loaded and finished
    return value, value
  end
end)(...)
