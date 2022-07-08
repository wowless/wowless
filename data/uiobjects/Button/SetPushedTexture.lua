return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.pushedTexture)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:SetShown(ud.buttonState == 'PUSHED')
  end
  ud.pushedTexture = t
end)(...)
