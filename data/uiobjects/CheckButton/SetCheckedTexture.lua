return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.checkedTexture)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:SetShown(ud.checked)
  end
  ud.checkedTexture = t
end)(...)
