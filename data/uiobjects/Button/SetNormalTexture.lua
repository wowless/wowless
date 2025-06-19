local api, toTexture = ...
return function(self, tex)
  local t = toTexture(self, tex, self.normalTexture)
  if t then
    api.SetParent(t, self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetShown(self.buttonState == 'NORMAL')
  end
  self.normalTexture = t
end
