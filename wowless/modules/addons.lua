return function(datalua)
  local addons = {}
  local tocversion = datalua.build.tocversion
  local function GetAddOnInfo(addon)
    if not addon then
      return 'FIXME', nil, nil, false, 'MISSING', 'INSECURE'
    else
      local name = addon.name
      local secure = addon.name:sub(1, 9) == 'Blizzard_' and 'SECURE' or 'INSECURE'
      return name, addon.attrs.Title or '', addon.attrs.Notes or '', true, '', secure
    end
  end

  local function GetAddOnInterfaceVersion(addon)
    if not addon then
      return 0
    end
    local v = addon.interface or 0
    -- The interface number in a TOC is a fixed value that may be too high for non-retail products.
    return v <= tocversion and v or 0
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
