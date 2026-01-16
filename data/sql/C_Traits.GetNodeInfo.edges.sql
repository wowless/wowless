SELECT
  edge.RightTraitNodeID AS TargetNodeID,
  edge.VisualStyle,
  edge.`Type`
FROM TraitNode AS node
INNER JOIN TraitEdge AS edge ON node.ID = edge.LeftTraitNodeID
INNER JOIN TraitNode AS targetNode ON edge.RightTraitNodeID = targetNode.ID
WHERE node.ID = ?1
ORDER BY targetNode.PosX -- TODO - find out how it's ordered
