SELECT sxt.TraitTreeID AS treeId
FROM SkillLine AS sl
INNER JOIN ChrClasses AS class ON sl.DisplayName_lang = class.Name_lang
INNER JOIN ChrSpecialization AS spec ON class.ID = spec.ClassID
INNER JOIN SkillLineXTraitTree AS sxt ON sl.ID = sxt.SkillLineID

WHERE
  (sl.Flags & 1048) = 1048
  AND spec.ID = ?1
