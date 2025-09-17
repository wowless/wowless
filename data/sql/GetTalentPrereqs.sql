SELECT
  Talent.TierID + 1,
  Talent.ColumnIndex + 1
FROM
  Talent -- noqa:aliasing.unique.table
INNER JOIN (
  SELECT
    Talent.PrereqTalent AS ID,
    ROW_NUMBER() OVER (
      ORDER BY
        Talent.ID
    ) AS RowNum
  FROM
    Talent
  INNER JOIN TalentTab ON Talent.TabID = TalentTab.ID
  WHERE
    TalentTab.ClassMask & (1 << (?1 - 1)) != 0
    AND TalentTab.OrderIndex = ?2 - 1
) AS Prereq ON Talent.ID = Prereq.ID
WHERE
  Prereq.RowNum = ?3;
