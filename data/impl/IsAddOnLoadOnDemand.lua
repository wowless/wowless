return (function(addons, addonIndexOrName)
  if type(addonIndexOrName) == 'string' then
    addonIndexOrName = addonIndexOrName:lower()
  end
  local addon = addons[addonIndexOrName]
  return addon and addon.attrs.LoadOnDemand == '1' and 1 or nil
end)(...)
