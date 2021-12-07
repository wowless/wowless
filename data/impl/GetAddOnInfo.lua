local addons, addonNameOrIndex = ...
local toc = addons[addonNameOrIndex]
if toc then
  local name = toc.name
  local secure = toc.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
  return name, toc.attrs.Title, toc.attrs.Notes, true, nil, secure
end
