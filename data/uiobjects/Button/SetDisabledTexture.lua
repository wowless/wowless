return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  if t then
    t:SetShown(ud.buttonState == 'DISABLED')
    if t:GetParent() == self and t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
  end
  ud.disabledTexture = t
end)(...)
