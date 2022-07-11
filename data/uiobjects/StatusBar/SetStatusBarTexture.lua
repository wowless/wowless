return (function(self, tex)
  local ud = u(self)
  local t = toTexture(self, tex, ud.statusBarTexture)
  if t then
    t:SetParent(self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:Show()
  end
  ud.statusBarTexture = t
end)(...)
