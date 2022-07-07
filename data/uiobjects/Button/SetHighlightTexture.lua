return (function(self, tex)
  local t = toTexture(self, tex)
  if t then
    t:Show()
    t:SetDrawLayer('HIGHLIGHT')
  end
  u(self).highlightTexture = t
end)(...)
