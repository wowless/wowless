return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  ud.normalTexture = t
  t:SetShown(ud.buttonState == 'NORMAL')
end)(...)
