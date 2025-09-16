SELECT `group`.ID
FROM TraitNode AS node
INNER JOIN TraitNodeGroupXTraitNode AS gxn ON node.ID = gxn.TraitNodeID
INNER JOIN TraitNodeGroup AS `group` ON `group`.ID = gxn.TraitNodeGroupID

WHERE node.ID = ?1
ORDER BY gxn.`Index`
