local function setShown(t, v)
  return t and t:SetShown(v)
end
return function(self, state, locked)
  self.buttonState = state
  self.buttonLocked = locked
  setShown(self.disabledTexture, state == 'DISABLED')
  setShown(self.normalTexture, state == 'NORMAL')
  setShown(self.pushedTexture, state == 'PUSHED')
end
