return (function(addons, addonIndexOrName)
  assert(type(addonIndexOrName) == 'string')
  local addon = addons[addonIndexOrName]
  return addon and addon.loaded or nil
end)(...)
