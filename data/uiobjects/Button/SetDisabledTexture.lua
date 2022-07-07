return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  ud.disabledTexture = t
  if t then
    t:SetShown(ud.buttonState == 'DISABLED')
  end
end)(...)
