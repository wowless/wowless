local T, GetAddOnInterfaceVersion = ...
return {
  build = function()
    return T.match(1, T.data.build.tocversion, GetAddOnInterfaceVersion('WowlessData'))
  end,
  nonsense = function()
    return T.match(1, 0, GetAddOnInterfaceVersion('WowlessNonsense'))
  end,
  wowless = function()
    -- The Wowless addon TOC has a fixed interface value of 120000, which is too high for non-retail.
    local expected = T.data.build.tocversion >= 120000 and 120000 or 0
    return T.match(1, expected, GetAddOnInterfaceVersion('Wowless'))
  end,
}
