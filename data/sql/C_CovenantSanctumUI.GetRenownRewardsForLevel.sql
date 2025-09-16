SELECT
  Description_lang AS description,
  GarrFollowerID AS garrFollowerID,
  Icon AS icon,
  MountID AS mountID,
  Name_lang AS name,
  SpellID AS spellID,
  CharTitlesID AS titleMaskID,
  ToastDescription_lang AS toastDescription,
  TransmogID AS transmogID,
  TransmogIllusionID AS transmogIllusionSourceID,
  TransmogSetID AS transmogSetID,
  UiOrder AS uiOrder,
  CASE WHEN ItemID != 0 THEN ItemID END AS itemID
FROM
  RenownRewards
WHERE
  CovenantID = ?1
  AND Level = ?2
ORDER BY
  UiOrder;
