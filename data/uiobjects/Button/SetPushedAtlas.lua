return function(self, atlas)
  if not self.pushedTexture then
    self:SetPushedTexture(self:CreateTexture().luarep)
  end
  self.pushedTexture:SetAtlas(atlas)
end
