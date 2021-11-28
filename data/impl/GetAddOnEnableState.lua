return (function(addons, _, addonIndexOrName)
  assert(type(addonIndexOrName) == 'string')
  return addons[addonIndexOrName] and 2 or 0
end)(...)
