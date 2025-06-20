SELECT
    COALESCE(cond1.ID, cond2.ID) AS ID,
    COALESCE(cond1.CondType, cond2.CondType) AS CondType,
    COALESCE(specset1.ChrSpecializationID, specset2.ChrSpecializationID, 0) AS specID
FROM TraitNode node
LEFT JOIN TraitNodeXTraitCond nxc ON nxc.TraitNodeID = node.ID
LEFT JOIN TraitNodeGroupXTraitNode gxn ON gxn.TraitNodeID = node.ID
LEFT JOIN TraitNodeGroup `group` ON `group`.ID = gxn.TraitNodeGroupID
LEFT JOIN TraitNodeGroupXTraitCond gxc ON gxc.TraitNodeGroupID  = `group`.ID
LEFT JOIN TraitCond cond1 ON cond1.ID = gxc.TraitCondID
LEFT JOIN TraitCond cond2 ON cond2.ID = nxc.TraitCondID
LEFT JOIN SpecSetMember specset1 ON specset1.SpecSet = cond1.SpecSetID
LEFT JOIN SpecSetMember specset2 ON specset2.SpecSet = cond2.SpecSetID

WHERE
    node.ID = ?1
    AND COALESCE(cond1.ID, cond2.ID) IS NOT NULL
-- TODO - figure out the actual order, if we care
