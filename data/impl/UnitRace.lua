local sql, unit = ...
if unit then
  return sql(unit.race)
end
