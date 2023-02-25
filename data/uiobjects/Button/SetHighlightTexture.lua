return (function(self, tex)
  local t = toTexture(self, tex, self.highlightTexture)
  if t then
    t:SetParent(self.luarep)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetDrawLayer('HIGHLIGHT')
    t:Show()
  end
  self.highlightTexture = t
end)(...)
