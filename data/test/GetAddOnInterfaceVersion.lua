local T, GetAddOnInterfaceVersion = ...
return {
  build = function()
    return T.match(1, T.data.build.tocversion, GetAddOnInterfaceVersion('WowlessData'))
  end,
  nonsense = function()
    return T.match(1, 0, GetAddOnInterfaceVersion('WowlessNonsense'))
  end,
  wowless = function()
    return T.match(1, T.data.build.tocversion, GetAddOnInterfaceVersion('Wowless'))
  end,
}
