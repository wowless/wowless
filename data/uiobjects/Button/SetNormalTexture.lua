return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.normalTexture)
  if t then
    t:SetParent(self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetShown(ud.buttonState == 'NORMAL')
  end
  ud.normalTexture = t
end)(...)
