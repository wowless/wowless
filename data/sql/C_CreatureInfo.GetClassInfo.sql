SELECT
  Filename AS classFile,
  ID AS classID,
  Name_lang AS className
FROM
  ChrClasses
WHERE
  ID = ?1;
