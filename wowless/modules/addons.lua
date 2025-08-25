return function()
  local addons = {}

  local function GetAddOnInfo(addon)
    if not addon then
      return 'FIXME', nil, nil, false, 'MISSING', 'INSECURE', false
    else
      local name = addon.name
      local secure = addon.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
      return name, addon.attrs.Title or '', addon.attrs.Notes or '', true, '', secure, false
    end
  end

  local function GetNumAddOns()
    return #addons
  end

  return {
    addons = addons,
    GetAddOnInfo = GetAddOnInfo,
    GetNumAddOns = GetNumAddOns,
  }
end
