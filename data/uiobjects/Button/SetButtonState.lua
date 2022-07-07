local validStates = {
  DISABLED = true,
  NORMAL = true,
  PUSHED = true,
}
return (function(self, state, locked)
  assert(type(state) == 'string' and validStates[state], 'invalid state')
  local ud = u(self)
  ud.buttonState = state
  ud.buttonLocked = locked
end)(...)
