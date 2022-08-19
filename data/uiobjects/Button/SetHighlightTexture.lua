return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.highlightTexture)
  if t then
    t:SetParent(self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetDrawLayer('HIGHLIGHT')
    t:Show()
  end
  ud.highlightTexture = t
end)(...)
