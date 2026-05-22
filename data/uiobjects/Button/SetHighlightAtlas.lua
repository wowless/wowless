return function(self, atlas)
  if not self.highlightTexture then
    self:SetHighlightTexture(self:CreateTexture())
  end
  self.highlightTexture:SetAtlas(atlas)
end
