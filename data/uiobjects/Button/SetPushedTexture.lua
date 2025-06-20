local api, toTexture = ...
return function(self, tex)
  local t = toTexture(self, tex, self.pushedTexture)
  if t then
    api.SetParent(t, self)
    if t:GetNumPoints() == 0 then
      t:SetAllPoints()
    end
    t:SetShown(self.buttonState == 'PUSHED')
  end
  self.pushedTexture = t
end
