local cvars, var, value = ...
cvars[var:lower()] = {
  name = var,
  value = value,
}
