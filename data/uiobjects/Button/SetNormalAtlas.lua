return function(self, atlas)
  if not self.normalTexture then
    self:SetNormalTexture(self:CreateTexture())
  end
  self.normalTexture:SetAtlas(atlas)
end
