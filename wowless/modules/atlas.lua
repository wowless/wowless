local band = require('bit').band

return function(env)
  local function GetAtlasInfo(
    elementName,
    atlasHeight,
    atlasWidth,
    fileDataID,
    committedBottom,
    committedFlags,
    committedLeft,
    committedRight,
    committedTop,
    overrideHeight,
    overrideWidth
  )
    if atlasHeight then
      return {
        bottomTexCoord = committedBottom / atlasHeight,
        elementName = elementName,
        file = fileDataID,
        height = overrideHeight ~= 0 and overrideHeight or committedBottom - committedTop,
        leftTexCoord = committedLeft / atlasWidth,
        rawSize = env.mixin({ x = 0, y = 0 }, 'Vector2DMixin'), -- TODO implement
        rightTexCoord = committedRight / atlasWidth,
        tilesHorizontally = band(committedFlags, 0x4) ~= 0,
        tilesVertically = band(committedFlags, 0x2) ~= 0,
        topTexCoord = committedTop / atlasHeight,
        width = overrideWidth ~= 0 and overrideWidth or committedRight - committedLeft,
      }
    end
  end

  local function SetAtlas(
    t,
    elementName,
    atlasHeight,
    atlasWidth,
    fileDataID,
    committedBottom,
    committedFlags,
    committedLeft,
    committedRight,
    committedTop
  )
    if atlasHeight then
      t:SetTexture(fileDataID)
      t:SetHorizTile(band(committedFlags, 0x4) ~= 0)
      t:SetVertTile(band(committedFlags, 0x2) ~= 0)
      t:SetTexCoord(
        committedLeft / atlasWidth,
        committedRight / atlasWidth,
        committedTop / atlasHeight,
        committedBottom / atlasHeight
      )
      t.atlas = elementName
    end
  end

  return {
    GetAtlasInfo = GetAtlasInfo,
    SetAtlas = SetAtlas,
  }
end
