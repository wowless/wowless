return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  ud.pushedTexture = t
  if t then
    t:SetShown(ud.buttonState == 'PUSHED')
  end
end)(...)
