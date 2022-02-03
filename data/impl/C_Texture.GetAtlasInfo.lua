local uitextureatlas, uitextureatlasmember, atlas = ...
local band = require('bit').band
atlas = atlas:lower()
for m in uitextureatlasmember() do
  if m.CommittedName:lower() == atlas then
    -- TODO use lookup by ID
    for a in uitextureatlas() do
      if a.ID == m.UiTextureAtlasID then
        return {
          bottomTexCoord = m.CommittedBottom,
          file = a.FileDataID,
          height = a.AtlasHeight,
          leftTexCoord = m.CommittedLeft,
          rightTexCoord = m.CommittedRight,
          tilesHorizontally = not not band(m.CommittedFlags, 0x4),
          tilesVertically = not not band(m.CommittedFlags, 0x2),
          topTexCoord = m.CommittedTop,
          width = a.AtlasWidth,
        }
      end
    end
  end
end
