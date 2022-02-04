local chrclasses, unit = ...
local row = unit and chrclasses(unit.class)
if row then
  return row.Filename, row.ID
end
