return function(self, atlas)
  if not self.disabledTexture then
    self:SetDisabledTexture(self:CreateTexture().luarep)
  end
  self.disabledTexture:SetAtlas(atlas)
end
