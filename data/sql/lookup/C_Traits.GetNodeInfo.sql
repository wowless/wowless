SELECT
    node.ID,
    node.PosX,
    node.PosY,
    node.`Type`,
    node.Flags
FROM TraitNode node

WHERE
    node.ID = ?1
