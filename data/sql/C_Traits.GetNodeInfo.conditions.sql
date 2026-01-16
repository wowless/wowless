SELECT
  COALESCE(cond1.ID, cond2.ID) AS ID,
  COALESCE(cond1.CondType, cond2.CondType) AS CondType,
  COALESCE(specset1.ChrSpecializationID, specset2.ChrSpecializationID, 0)
    AS specID
FROM TraitNode AS node
LEFT JOIN TraitNodeXTraitCond AS nxc ON node.ID = nxc.TraitNodeID
LEFT JOIN TraitNodeGroupXTraitNode AS gxn ON node.ID = gxn.TraitNodeID
LEFT JOIN TraitNodeGroup AS `group` ON gxn.TraitNodeGroupID = `group`.ID
LEFT JOIN TraitNodeGroupXTraitCond AS gxc ON `group`.ID = gxc.TraitNodeGroupID
LEFT JOIN TraitCond AS cond1 ON gxc.TraitCondID = cond1.ID
LEFT JOIN TraitCond AS cond2 ON nxc.TraitCondID = cond2.ID
LEFT JOIN SpecSetMember AS specset1 ON cond1.SpecSetID = specset1.SpecSet
LEFT JOIN SpecSetMember AS specset2 ON cond2.SpecSetID = specset2.SpecSet

WHERE
  node.ID = ?1
  AND COALESCE(cond1.ID, cond2.ID) IS NOT NULL
-- TODO - figure out the actual order, if we care
