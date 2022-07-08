return (function(self, tex)
  local t = toTexture(self, tex)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:SetDrawLayer('HIGHLIGHT')
    t:Show()
  end
  u(self).highlightTexture = t
end)(...)
