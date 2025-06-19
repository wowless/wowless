local api = ...
return function(self, atlas)
  local t = self:GetDisabledTexture()
  if not t then
    t = self:CreateTexture()
    self:SetDisabledTexture(t)
  end
  api.UserData(t):SetAtlas(atlas)
end
