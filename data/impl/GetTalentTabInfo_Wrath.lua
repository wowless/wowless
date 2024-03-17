local api, sql, tabIndex = ... -- TODO honor isInspect
local name, filename = sql(api.modules.units.player.class, tabIndex)
return name, nil, 0, filename, 0
