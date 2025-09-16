SELECT COUNT(*)
FROM
  ChrSpecialization
WHERE
  ClassID = ?1
  AND OrderIndex != 4;
