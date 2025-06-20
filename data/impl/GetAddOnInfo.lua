return function(addon)
  if not addon then
    return 'FIXME', nil, nil, false, 'MISSING', 'INSECURE', false
  else
    local name = addon.name
    local secure = addon.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
    return name, addon.attrs.Title or '', addon.attrs.Notes or '', true, '', secure, false
  end
end
