local api = ...
return function(self, atlas)
  local t = self:GetNormalTexture()
  if not t then
    t = self:CreateTexture()
    self:SetNormalTexture(t)
  end
  api.UserData(t):SetAtlas(atlas)
end
