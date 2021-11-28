return (function(addons, addon, field)
  local toc = addons[addon]
  return toc and toc.attrs[field] or nil
end)(...)
