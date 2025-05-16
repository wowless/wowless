SELECT
  Filename AS classFile,
  ID as classID,
  Name_lang AS className
FROM
  ChrClasses
WHERE
  ID == ?1;
