SELECT
  p.PowerTypeEnum AS powerType,
  p.NameGlobalStringTag AS powerToken,
  0 AS altR,
  0 AS altG,
  0 AS altB
FROM
  PowerType AS p
INNER JOIN ChrClassesXPowerTypes AS x ON p.PowerTypeEnum = x.PowerType
WHERE
  x.ClassID = ?1
LIMIT
  1;
