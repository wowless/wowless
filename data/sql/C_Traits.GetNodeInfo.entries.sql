SELECT
    nodeXentry.TraitNodeEntryID,
    entry.MaxRanks
FROM TraitNodeXTraitNodeEntry nodeXentry
JOIN TraitNodeEntry entry ON entry.ID = nodeXentry.TraitNodeEntryID
WHERE
    nodeXentry.TraitNodeID = ?1
