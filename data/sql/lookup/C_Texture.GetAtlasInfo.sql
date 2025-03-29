SELECT
  a.AtlasHeight,
  a.AtlasWidth,
  a.FileDataID,
  m.CommittedBottom,
  m.CommittedFlags,
  m.CommittedLeft,
  m.CommittedRight,
  m.CommittedTop,
  m.OverrideHeight,
  m.OverrideWidth
FROM
  UiTextureAtlasMember m
  JOIN UiTextureAtlas a ON a.ID = m.UiTextureAtlasID
WHERE
  m.CommittedName = ?1 COLLATE NOCASE;
