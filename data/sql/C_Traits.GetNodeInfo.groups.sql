SELECT
    `group`.ID
FROM TraitNode node
JOIN TraitNodeGroupXTraitNode gxn ON gxn.TraitNodeID = node.ID
JOIN TraitNodeGroup `group` ON `group`.ID = gxn.TraitNodeGroupID

WHERE node.ID = ?1
ORDER BY gxn.`Index`
