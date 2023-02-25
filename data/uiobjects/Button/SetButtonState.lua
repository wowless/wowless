local function setShown(t, v)
  return t and t:SetShown(v)
end
return (function(self, state, locked)
  local d = state == 'DISABLED'
  local n = state == 'NORMAL'
  local p = state == 'PUSHED'
  assert(d or n or p, 'invalid state')
  self.buttonState = state
  self.buttonLocked = locked
  setShown(self.disabledTexture, d)
  setShown(self.normalTexture, n)
  setShown(self.pushedTexture, p)
end)(...)
