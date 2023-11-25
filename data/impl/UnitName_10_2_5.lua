local units, token = ...
-- TODO unit resolution API
local unit = units.guids[units.aliases[token:lower()]]
return unit and unit.name or '', ''
