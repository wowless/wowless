local uiobjects = ...
return function(self, atlas)
  local t = self:GetDisabledTexture()
  if not t then
    t = self:CreateTexture()
    self:SetDisabledTexture(t)
  end
  uiobjects.UserData(t):SetAtlas(atlas)
end
