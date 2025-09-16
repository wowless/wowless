SELECT
  ID AS mapID,
  Name_Lang AS name,
  ParentUiMapID AS parentMapID,
  "Type" AS mapType
FROM
  UiMap
WHERE
  ID = ?1;
