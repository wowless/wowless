SELECT ChrSpecializationID
FROM
  SpecSetMember
WHERE
  SpecSet = ?1
ORDER BY
  ID;
