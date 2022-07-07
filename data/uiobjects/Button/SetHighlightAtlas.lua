return (function(self, atlas)
  local t = self:GetHighlightTexture()
  if not t then
    t = self:CreateTexture()
    self:SetHighlightTexture(t)
  end
  t:SetAtlas(atlas)
end)(...)
