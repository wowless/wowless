local api, toTexture = ...
return function(self, tex)
  local t = toTexture(self, tex, self.checkedTexture)
  if t then
    api.SetParent(t, self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetShown(self.checked)
  end
  self.checkedTexture = t
end
