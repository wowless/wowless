return (function(addons, _, addonIndexOrName)
  if type(addonIndexOrName) == 'string' then
    addonIndexOrName = addonIndexOrName:lower()
  end
  return addons[addonIndexOrName] and 2 or 0
end)(...)
