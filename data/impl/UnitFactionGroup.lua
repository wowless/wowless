local factiongroup, unit = ...
local row = unit and factiongroup(unit.faction)
if row then
  return row.InternalName, row.Name_lang
end
