local renownrewards, covenantID, renownLevel = ...
local t = {}
for row in renownrewards() do
  if row.CovenantID == covenantID and row.Level == renownLevel then
    table.insert(t, {
      description = row.Description_lang,
      garrFollowerID = row.GarrFollowerID,
      icon = row.Icon,
      itemID = row.ItemID,
      mountID = row.MountID,
      name = row.Name_lang,
      spellID = row.SpellID,
      titleMaskID = row.CharTitlesID,
      toastDescription = row.ToastDescription_lang,
      transmogID = row.TransmogID,
      transmogIllusionSourceID = row.TransmogIllusionID,
      transmogSetID = row.TransmogSetID,
      uiOrder = row.UiOrder,
    })
  end
end
table.sort(t, function(a, b)
  return a.uiOrder < b.uiOrder
end)
return t
