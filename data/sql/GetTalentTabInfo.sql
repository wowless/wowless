SELECT
  Name_lang,
  BackgroundFile
FROM
  TalentTab
WHERE
  ClassMask & (1 << (?1 - 1)) != 0
  AND OrderIndex = ?2 - 1;
