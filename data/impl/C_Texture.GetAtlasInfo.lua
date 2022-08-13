local uitextureatlas, uitextureatlasmember, atlasName = ...
local m = uitextureatlasmember(atlasName)
if m then
  local a = uitextureatlas(m.UiTextureAtlasID)
  if a then
    local band = require('bit').band
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
