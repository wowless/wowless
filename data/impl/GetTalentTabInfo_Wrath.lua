local units, sql, tabIndex = ... -- TODO honor isInspect
local name, filename = sql(units.guids[units.aliases.player].class, tabIndex)
return name, nil, 0, filename, 0
