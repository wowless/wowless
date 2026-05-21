return function(self, atlas)
  if not self.pushedTexture then
    self:SetPushedTexture(self:CreateTexture())
  end
  self.pushedTexture:SetAtlas(atlas)
end
