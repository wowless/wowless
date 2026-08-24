return function(datalua)
  local addons = {}
  local tocversion = datalua.build.tocversion
  local function GetAddOnInfo(addon)
    if not addon then
      return 'FIXME', nil, nil, false, 'MISSING', 'INSECURE'
    else
      local name = addon.name
      local secure = addon.signed and 'SECURE' or 'INSECURE'
      return name, addon.attrs.Title or '', addon.attrs.Notes or '', true, '', secure
    end
  end

  local function GetAddOnInterfaceVersion(addon)
    if not addon then
      return 0
    end
    local best = 0
    for _, v in ipairs(addon.interface or {}) do
      if v <= tocversion and v > best then
        best = v
      end
    end
    return best
  end

  local function GetNumAddOns()
    return #addons
  end

  return {
    addons = addons,
    GetAddOnInfo = GetAddOnInfo,
    GetAddOnInterfaceVersion = GetAddOnInterfaceVersion,
    GetNumAddOns = GetNumAddOns,
  }
end
