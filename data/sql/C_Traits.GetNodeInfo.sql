SELECT
  node.ID,
  node.PosX,
  node.PosY,
  node.`Type`,
  node.Flags
FROM TraitNode AS node

WHERE
  node.ID = ?1
