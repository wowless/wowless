return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.normalTexture)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:SetShown(ud.buttonState == 'NORMAL')
  end
  ud.normalTexture = t
end)(...)
