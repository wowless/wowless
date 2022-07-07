return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex)
  ud.normalTexture = t
  t:SetShown(ud.buttonState == 'NORMAL')
  -- TODO validate with reference
  if t:GetParent() == self and t:GetNumPoints() == 0 then
    t:SetAllPoints()
  end
end)(...)
