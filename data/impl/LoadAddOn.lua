local loader, addon = ...
if not addon then
  error('unknown addon')
end
return loader.loadAddon(addon and addon.name)
