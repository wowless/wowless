SELECT
  Name,
  Icon,
  _Row,
  _Column,
  0,
  1,
  0,
  0
FROM
  (
    SELECT
      SpellName.Name_lang AS Name,
      SpellMisc.SpellIconFileDataID AS Icon,
      ROW_NUMBER() OVER (
        ORDER BY
          Talent.ID
      ) AS RowNum,
      Talent.TierID + 1 AS _Row,
      Talent.ColumnIndex + 1 AS _Column
    FROM
      Talent
    INNER JOIN TalentTab ON Talent.TabID = TalentTab.ID
    INNER JOIN SpellName ON Talent.SpellRank = SpellName.ID
    INNER JOIN SpellMisc ON Talent.SpellRank = SpellMisc.SpellID
    WHERE
      TalentTab.ClassMask & (1 << (?1 - 1)) != 0
      AND TalentTab.OrderIndex = ?2 - 1
  )
WHERE
  RowNum = ?3;
