local sql, unit = ...
if unit then
  return sql(unit.class)
end
