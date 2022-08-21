SELECT
  Talent.TierID + 1,
  Talent.ColumnIndex + 1
FROM
  Talent
  JOIN (
    SELECT
      ROW_NUMBER() OVER(
        ORDER BY
          Talent.ID
      ) AS RowNum,
      Talent.PrereqTalent AS ID
    FROM
      Talent
      JOIN TalentTab ON Talent.TabID == TalentTab.ID
    WHERE
      TalentTab.ClassMask & (1 << (?1 - 1)) != 0
      AND TalentTab.OrderIndex == ?2 - 1
  ) Prereq ON Prereq.ID = Talent.ID
WHERE
  Prereq.RowNum == ?3;
