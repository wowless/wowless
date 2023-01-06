SELECT
    cond.ID,
    cond.CondType,
    COALESCE(specset.ChrSpecializationID, 0) AS specID
FROM TraitNode node
LEFT JOIN TraitNodeXTraitCond nxc ON nxc.TraitNodeID = node.ID
LEFT JOIN TraitNodeGroupXTraitNode gxn ON gxn.TraitNodeID = node.ID
LEFT JOIN TraitNodeGroup `group` ON `group`.ID = gxn.TraitNodeGroupID
LEFT JOIN TraitNodeGroupXTraitCond gxc ON gxc.TraitNodeGroupID  = `group`.ID
LEFT JOIN TraitCond cond ON (cond.ID = gxc.TraitCondID OR cond.ID = nxc.TraitCondID)
LEFT JOIN SpecSetMember specset ON specset.SpecSet = cond.SpecSetID

WHERE
    node.ID = ?1
    AND cond.ID IS NOT NULL
ORDER BY gxn."Index", cond.CondType -- TODO - is this the correct order?
