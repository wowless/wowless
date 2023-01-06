SELECT
    edge.RightTraitNodeID as TargetNodeID,
    edge.VisualStyle,
    edge.`Type`
FROM TraitNode node
JOIN TraitEdge edge ON edge.LeftTraitNodeID = node.ID
JOIN TraitNode targetNode ON edge.RightTraitNodeID = targetNode.ID
WHERE node.ID = ?1
ORDER BY targetNode.PosX -- TODO - find out how it's ordered
