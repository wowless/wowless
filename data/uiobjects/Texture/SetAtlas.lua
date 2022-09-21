return (function(self, name)
  if name == nil then
    -- TODO error here instead of silently ignoring
    return
  end
  local t = api.env('get', 'C_Texture').GetAtlasInfo(name)
  if t == nil then
    -- TODO determine if we should error here instead of silently ignoring
    return
  end
  m(self, 'SetTexture', t.filename or tostring(t.file))
  m(self, 'SetHorizTile', t.tilesHorizontally)
  m(self, 'SetVertTile', t.tilesVertically)
  m(self, 'SetTexCoord', t.leftTexCoord, t.rightTexCoord, t.topTexCoord, t.bottomTexCoord)
end)(...)
