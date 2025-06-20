local UnitPowerTypeSqlLookup = ...
return function(unit)
  if unit and unit.class then
    return UnitPowerTypeSqlLookup(unit.class)
  end
end
