return (function(self, tex)
  local t = toTexture(self, tex)
  if t then
    t:Show()
    t:SetDrawLayer('HIGHLIGHT')
    if t:GetParent() == self and t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
  end
  u(self).highlightTexture = t
end)(...)
