local addons = ...
return function(addon)
  if not addon then
    error('unknown addon')
  end
  return addons.loadAddon(addon and addon.name)
end
