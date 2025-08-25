return function(datalua)
  local addons = {}
  local config = datalua.config.modules and datalua.config.modules.addons or {}

  local getAddOnInfoUpdateAvailable
  if config.GetAddOnInfo_noUpdateAvailable then
    getAddOnInfoUpdateAvailable = function() end
  else
    getAddOnInfoUpdateAvailable = function()
      return false
    end
  end

  local function GetAddOnInfo(addon)
    if not addon then
      return 'FIXME', nil, nil, false, 'MISSING', 'INSECURE', getAddOnInfoUpdateAvailable()
    else
      local name = addon.name
      local secure = addon.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
      return name, addon.attrs.Title or '', addon.attrs.Notes or '', true, '', secure, getAddOnInfoUpdateAvailable()
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
