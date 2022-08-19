return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.disabledTexture)
  if t then
    t:SetParent(self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetShown(ud.buttonState == 'DISABLED')
  end
  ud.disabledTexture = t
end)(...)
