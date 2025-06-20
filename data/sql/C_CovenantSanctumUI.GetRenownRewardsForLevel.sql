SELECT
  Description_lang AS description,
  GarrFollowerID AS garrFollowerID,
  Icon AS icon,
  CASE WHEN ItemID != 0 THEN ItemID ELSE NULL END AS itemID,
  MountID AS mountID,
  Name_lang AS name,
  SpellID AS spellID,
  CharTitlesID AS titleMaskID,
  ToastDescription_lang AS toastDescription,
  TransmogID AS transmogID,
  TransmogIllusionID AS transmogIllusionSourceID,
  TransmogSetID AS transmogSetID,
  UiOrder AS uiOrder
FROM
  RenownRewards
WHERE
  CovenantID == ?1
  And Level == ?2
ORDER BY
  UiOrder;
