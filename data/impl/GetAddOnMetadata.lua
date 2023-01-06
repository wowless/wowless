return (function(addons, addon, field)
  if type(addon) == 'string' then
    addon = addon:lower()
  end
  local toc = addons[addon]
  return toc and toc.attrs[field] or nil
end)(...)
