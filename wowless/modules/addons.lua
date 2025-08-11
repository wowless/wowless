return function()
  local addons = {}

  local function GetNumAddOns()
    return #addons
  end

  return {
    addons = addons,
    GetNumAddOns = GetNumAddOns,
  }
end
