SELECT
  COUNT(*)
FROM
  Talent
  JOIN TalentTab ON Talent.TabID = TalentTab.ID
WHERE
  TalentTab.ClassMask & (1 << (?1 - 1)) != 0
  AND TalentTab.OrderIndex == ?2 - 1;
