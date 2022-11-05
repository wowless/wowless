local addons, addonNameOrIndex = ...
if type(addonNameOrIndex) == 'string' then
  addonNameOrIndex = addonNameOrIndex:lower()
end
local toc = addons[addonNameOrIndex]
if tonumber(addonNameOrIndex) and not toc then
  error('AddOn index must be in the range of 1 to ' .. #addons)
elseif not toc then
  return addonNameOrIndex, nil, nil, false, 'MISSING', 'INSECURE', false
else
  local name = toc.name
  local secure = toc.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
  return name, toc.attrs.Title, toc.attrs.Notes, true, nil, secure, false
end
