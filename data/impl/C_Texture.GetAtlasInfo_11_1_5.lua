local GetAtlasInfoSqlLookup = ...
local band = require('bit').band
return function(atlasName)
  -- stylua: ignore
  local elementName, atlasHeight, atlasWidth, fileDataID, committedBottom,
        committedFlags, committedLeft, committedRight,
        committedTop, overrideHeight, overrideWidth = GetAtlasInfoSqlLookup(atlasName)
  if elementName then
    return {
      bottomTexCoord = committedBottom / atlasHeight,
      elementName = elementName,
      file = fileDataID,
      height = overrideHeight ~= 0 and overrideHeight or committedBottom - committedTop,
      leftTexCoord = committedLeft / atlasWidth,
      rawSize = { x = 0, y = 0 }, -- TODO implement
      rightTexCoord = committedRight / atlasWidth,
      tilesHorizontally = band(committedFlags, 0x4) ~= 0,
      tilesVertically = band(committedFlags, 0x2) ~= 0,
      topTexCoord = committedTop / atlasHeight,
      width = overrideWidth ~= 0 and overrideWidth or committedRight - committedLeft,
    }
  end
end
