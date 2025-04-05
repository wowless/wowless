local T = ...
local fn = T.env.GetAddOnMetadata or T.env.C_AddOns.GetAddOnMetadata
return {
  missing = function()
    T.check1(nil, fn('Wowless', 'WowlessNonsense'))
  end,
  present = function()
    T.check1('WoW client unit tests', fn('Wowless', 'Notes'))
  end,
}
