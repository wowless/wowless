return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.disabledTexture)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:SetShown(ud.buttonState == 'DISABLED')
  end
  ud.disabledTexture = t
end)(...)
