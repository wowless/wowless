return (function(addons, _, addonIndexOrName)
  local addon = addons[addonIndexOrName]
  return addon and addon.enabledState or 0
end)(...)
