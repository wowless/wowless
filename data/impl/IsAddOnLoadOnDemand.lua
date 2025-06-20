return function(addon)
  return addon and addon.attrs.LoadOnDemand == '1' and 1 or nil
end
