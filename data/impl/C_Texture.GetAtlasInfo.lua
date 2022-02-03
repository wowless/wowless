local uitextureatlas, uitextureatlasmember, atlas = ...
local band = require('bit').band
atlas = atlas:lower()
for m in uitextureatlasmember() do
  if m.CommittedName:lower() == atlas then
    -- TODO use lookup by ID
    for a in uitextureatlas() do
      if a.ID == m.UiTextureAtlasID then
        return {
          bottomTexCoord = m.CommittedBottom / a.AtlasHeight,
          file = a.FileDataID,
          height = m.OverrideHeight ~= 0 and m.OverrideHeight or m.CommittedBottom - m.CommittedTop,
          leftTexCoord = m.CommittedLeft / a.AtlasWidth,
          rightTexCoord = m.CommittedRight / a.AtlasWidth,
          tilesHorizontally = band(m.CommittedFlags, 0x4) ~= 0,
          tilesVertically = band(m.CommittedFlags, 0x2) ~= 0,
          topTexCoord = m.CommittedTop / a.AtlasHeight,
          width = m.OverrideWidth ~= 0 and m.OverrideWidth or m.CommittedRight - m.CommittedLeft,
        }
      end
    end
  end
end
