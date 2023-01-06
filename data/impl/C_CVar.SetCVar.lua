local cvars, var, value = ...
-- TODO assert cvar exists
cvars[var:lower()] = {
  name = var,
  value = value,
}
return true
