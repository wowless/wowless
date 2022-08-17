local UnitPowerTypeSqlLookup, unit = ...
if unit and unit.class then
  return UnitPowerTypeSqlLookup(unit.class)
else
  return 0, nil
end
