return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  ud.disabledTexture = t
  t:SetShown(ud.buttonState == 'DISABLED')
end)(...)
