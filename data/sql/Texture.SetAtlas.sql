SELECT
  e.Name,
  a.AtlasHeight,
  a.AtlasWidth,
  a.FileDataID,
  m.CommittedBottom,
  m.CommittedFlags,
  m.CommittedLeft,
  m.CommittedRight,
  m.CommittedTop
FROM
  UiTextureAtlasMember AS m
INNER JOIN UiTextureAtlas AS a ON m.UiTextureAtlasID = a.ID
INNER JOIN UiTextureAtlasElement AS e ON m.UiTextureAtlasElementID = e.ID
WHERE
  e.Name = ?1 COLLATE NOCASE; -- noqa
