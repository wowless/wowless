local api = ...
return function(self, name)
  if name == nil then
    -- TODO error here instead of silently ignoring
    return
  end
  local t = api.impls.C_Texture.GetAtlasInfo(name)
  if t == nil then
    -- TODO determine if we should error here instead of silently ignoring
    return
  end
  self:SetTexture(t.filename or tostring(t.file))
  self:SetHorizTile(t.tilesHorizontally)
  self:SetVertTile(t.tilesVertically)
  self:SetTexCoord(t.leftTexCoord, t.rightTexCoord, t.topTexCoord, t.bottomTexCoord)
  self.atlas = t.elementName or name
end
