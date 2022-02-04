local chrclasses, unit = ...
local row = unit and chrclasses(unit.class)
if row then
  return row.Name_lang, row.Filename, row.ID
end
