local uiobjects = ...
return function(self, atlas)
  local t = self:GetPushedTexture()
  if not t then
    t = self:CreateTexture()
    self:SetPushedTexture(t)
  end
  uiobjects.UserData(t):SetAtlas(atlas)
end
