return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.highlightTexture)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:SetDrawLayer('HIGHLIGHT')
    t:Show()
  end
  ud.highlightTexture = t
end)(...)
