return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  if t then
    t:SetShown(ud.buttonState == 'PUSHED')
    if t:GetParent() == self and t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
  end
  ud.pushedTexture = t
end)(...)
