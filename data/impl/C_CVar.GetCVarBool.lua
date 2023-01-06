local datalua, cvars, var = ...
local lvar = var:lower()
local t = cvars[lvar] or datalua.cvars[lvar]
return t and t.value == '1'
