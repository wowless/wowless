return (function(self, atlas)
  local t = self:GetPushedTexture()
  if not t then
    t = self:CreateTexture()
    self:SetPushedTexture(t)
  end
  t:SetAtlas(atlas)
end)(...)
