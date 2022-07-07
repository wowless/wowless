return (function(self, atlas)
  local t = self:GetDisabledTexture()
  if not t then
    t = self:CreateTexture()
    self:SetDisabledTexture(t)
  end
  t:SetAtlas(atlas)
end)(...)
