local T = ...
local fn = T.env.GetAddOnMetadata or T.env.C_AddOns.GetAddOnMetadata
return {
  missing = function()
    return T.match(1, nil, fn('Wowless', 'WowlessNonsense'))
  end,
  present = function()
    return T.match(1, 'WoW client unit tests', fn('Wowless', 'Notes'))
  end,
}
