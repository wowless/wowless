SELECT
  Filename,
  CASE WHEN ?1 THEN Name_female_lang ELSE Name_male_lang END
FROM
  ChrClasses;
