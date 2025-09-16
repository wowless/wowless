SELECT
  p.PowerTypeEnum,
  p.NameGlobalStringTag,
  0,
  0,
  0
FROM
  PowerType AS p
INNER JOIN ChrClassesXPowerTypes AS x ON p.PowerTypeEnum = x.PowerType
WHERE
  x.ClassID = ?1
LIMIT
  1;
