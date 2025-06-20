SELECT
  SlotNumber,
  SlotIconFileID
FROM
  PaperDollItemFrame
WHERE
  LOWER(ItemButtonName) == LOWER(?1);
