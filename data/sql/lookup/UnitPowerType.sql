SELECT
  p.PowerTypeEnum,
  p.NameGlobalStringTag
FROM
  PowerType p
  JOIN ChrClassesXPowerTypes x ON x.PowerType == p.PowerTypeEnum
WHERE
  x.ClassID = ?1
LIMIT
  1;
