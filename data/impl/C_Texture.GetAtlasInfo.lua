local GetAtlasInfoSqlLookup, atlasName = ...
-- stylua: ignore
local atlasHeight, atlasWidth, fileDataID, committedBottom,
      committedFlags, committedLeft, committedRight,
      committedTop, overrideHeight, overrideWidth = GetAtlasInfoSqlLookup(atlasName)
if atlasHeight then
  local band = require('bit').band
  return {
    bottomTexCoord = committedBottom / atlasHeight,
    file = fileDataID,
    height = overrideHeight ~= 0 and overrideHeight or committedBottom - committedTop,
    leftTexCoord = committedLeft / atlasWidth,
    rightTexCoord = committedRight / atlasWidth,
    tilesHorizontally = band(committedFlags, 0x4) ~= 0,
    tilesVertically = band(committedFlags, 0x2) ~= 0,
    topTexCoord = committedTop / atlasHeight,
    width = overrideWidth ~= 0 and overrideWidth or committedRight - committedLeft,
  }
end
