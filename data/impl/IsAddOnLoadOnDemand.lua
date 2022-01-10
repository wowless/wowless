return (function(addons, addonIndexOrName)
  local addon = addons[addonIndexOrName]
  return addon and addon.attrs.LoadOnDemand == '1' and 1 or nil
end)(...)
