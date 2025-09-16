SELECT
  ID,
  CASE WHEN ?2 = 3 THEN FemaleName_lang ELSE Name_lang END,
  Description_lang,
  SpellIconFileID,
  CASE
    WHEN Role = 0 THEN 'TANK'
    WHEN Role = 1 THEN 'HEALER'
    WHEN Role = 2 THEN 'DAMAGER'
  END,
  ClassID,
  MasterySpellID
FROM
  ChrSpecialization
WHERE
  ID = ?1;
