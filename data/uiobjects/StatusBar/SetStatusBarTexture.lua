return (function(self, tex)
  local t = toTexture(self, tex, self.statusBarTexture)
  if t then
    api.SetParent(t, self)
    t:ClearAllPoints()
    t:SetAllPoints()
    t:Show()
  end
  self.statusBarTexture = t
  if api.datalua.config.runtime.texturekitstatus then
    return true
  end
end)(...)
