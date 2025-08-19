local uiobjects = ...
return function(self, atlas)
  local t = self:GetHighlightTexture()
  if not t then
    t = self:CreateTexture()
    self:SetHighlightTexture(t)
  end
  uiobjects.UserData(t):SetAtlas(atlas)
end
