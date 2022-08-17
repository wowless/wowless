local units, sql, tabIndex = ... -- TODO honor isInspect
return sql(units.guids[units.aliases.player].class, tabIndex)
