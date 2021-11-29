return (function(addons, addonIndexOrName)
  local addon = addons[addonIndexOrName]
  return addon and addon.loaded or nil
end)(...)
