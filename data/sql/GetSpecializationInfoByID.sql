SELECT
  Spec.ID,
  CASE WHEN ?2 == 3 THEN Spec.FemaleName_lang ELSE Spec.Name_lang END,
  Spec.Description_lang,
  Spec.SpellIconFileID,
  CASE
    WHEN Spec.Role == 0 THEN 'TANK'
    WHEN Spec.Role == 1 THEN 'HEALER'
    WHEN Spec.Role == 2 THEN 'DAMAGER'
  END,
  ChrClasses.Filename,
  ChrClasses.Name_lang
FROM
  ChrSpecialization AS Spec
  JOIN ChrClasses ON Spec.ClassID == ChrClasses.ID
WHERE
  Spec.ID == ?1;
