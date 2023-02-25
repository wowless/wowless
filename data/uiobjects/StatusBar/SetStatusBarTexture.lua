return (function(self, tex)
  local t = toTexture(self, tex, self.statusBarTexture)
  if t then
    t:SetParent(self.luarep)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:Show()
  end
  self.statusBarTexture = t
end)(...)
