return function(self, atlas)
  if not self.normalTexture then
    self:SetNormalTexture(self:CreateTexture().luarep)
  end
  self.normalTexture:SetAtlas(atlas)
end
