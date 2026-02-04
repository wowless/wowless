SELECT
  Name_lang,
  Filename,
  ID
FROM
  ChrClasses
WHERE
  ID >= ?1
ORDER BY ID
LIMIT 1;
