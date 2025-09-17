SELECT
  COALESCE(NULLIF(VerboseName_lang, ''), DisplayName_lang) AS subClassName,
  Flags & 0x200 AS subClassUsesInvType
FROM
  ItemSubClass
WHERE
  ClassID = ?1
  AND SubClassID = ?2;
