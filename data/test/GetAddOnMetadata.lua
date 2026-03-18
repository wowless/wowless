local T, GetAddOnMetadata = ...
return {
  missing = function()
    return T.match(1, nil, GetAddOnMetadata('Wowless', 'WowlessNonsense'))
  end,
  present = function()
    return T.match(1, 'WoW client unit tests', GetAddOnMetadata('Wowless', 'Notes'))
  end,
}
