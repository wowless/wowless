local cvars, var, value = ...
cvars[var:lower()] = value
-- TODO assert cvar exists
return true
