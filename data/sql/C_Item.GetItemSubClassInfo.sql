SELECT
  COALESCE(NULLIF(VerboseName_lang, ''), DisplayName_lang),
  Flags & 0x200
FROM
  ItemSubClass
WHERE
  ClassID == ?1
  AND SubClassID == ?2;
