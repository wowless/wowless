local function setShown(t, v)
  return t and t:SetShown(v)
end
return (function(self, state, locked)
  local ud = u(self)
  local d = state == 'DISABLED'
  local n = state == 'NORMAL'
  local p = state == 'PUSHED'
  assert(d or n or p, 'invalid state')
  ud.buttonState = state
  ud.buttonLocked = locked
  setShown(ud.disabledTexture, d)
  setShown(ud.normalTexture, n)
  setShown(ud.pushedTexture, p)
end)(...)
