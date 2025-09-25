SELECT
  nodeXentry.TraitNodeEntryID,
  entry.MaxRanks
FROM TraitNodeXTraitNodeEntry AS nodeXentry
INNER JOIN TraitNodeEntry AS entry ON nodeXentry.TraitNodeEntryID = entry.ID
WHERE
  nodeXentry.TraitNodeID = ?1
