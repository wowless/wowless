SELECT
    sxt.TraitTreeID AS treeId,
    spec.Name_lang AS specName
FROM SkillLine sl
JOIN ChrClasses class ON sl.DisplayName_lang = class.Name_lang
JOIN ChrSpecialization spec ON class.ID = spec.ClassID
JOIN SkillLineXTraitTree sxt ON sxt.SkillLineID = sl.ID

WHERE
    (sl.Flags & 1048) = 1048
    AND spec.ID = ?1
