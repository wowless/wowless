SELECT COUNT(*)
FROM
  TalentTab
WHERE
  ClassMask & (1 << (?1 - 1)) != 0;
