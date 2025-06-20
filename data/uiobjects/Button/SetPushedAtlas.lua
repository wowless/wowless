local api = ...
return function(self, atlas)
  local t = self:GetPushedTexture()
  if not t then
    t = self:CreateTexture()
    self:SetPushedTexture(t)
  end
  api.UserData(t):SetAtlas(atlas)
end
