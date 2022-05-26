local chrclassesxpowertypes, powertype, unit = ...
local join = unit and chrclassesxpowertypes(unit.class)
local row = join and powertype(join.PowerType)
if row then
  return row.PowerTypeEnum, row.NameGlobalStringTag
else
  return 0
end
