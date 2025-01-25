local sql, unit = ...
if unit then
  return sql(unit.faction)
else
  return nil, nil
end
