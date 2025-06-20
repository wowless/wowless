SELECT
  Name,
  Icon,
  Row,
  Column,
  0,
  1,
  FALSE
FROM
  (
    SELECT
      ROW_NUMBER() OVER(
        ORDER BY
          Talent.ID
      ) AS RowNum,
      SpellName.Name_lang AS Name,
      SpellMisc.SpellIconFileDataID AS Icon,
      Talent.TierID + 1 AS Row,
      Talent.ColumnIndex + 1 AS Column
    FROM
      Talent
      JOIN TalentTab ON Talent.TabID == TalentTab.ID
      JOIN SpellName ON Talent.SpellRank == SpellName.ID
      JOIN SpellMisc ON Talent.SpellRank == SpellMisc.SpellID
    WHERE
      TalentTab.ClassMask & (1 << (?1 - 1)) != 0
      AND TalentTab.OrderIndex == ?2 - 1
  )
WHERE
  RowNum == ?3;
