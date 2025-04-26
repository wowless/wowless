local api, sql, tabIndex = ... -- TODO honor isInspect
local name, filename = sql(api.modules.units.player.class, tabIndex)
return nil, name, nil, nil, 0, filename, 0, false
