local UnitPowerTypeSqlLookup, unit = ...
if unit and unit.class then
  return UnitPowerTypeSqlLookup(unit.class)
end
