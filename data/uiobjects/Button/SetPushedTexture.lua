return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.pushedTexture)
  if t then
    t:SetParent(self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetShown(ud.buttonState == 'PUSHED')
  end
  ud.pushedTexture = t
end)(...)
