local factiongroup, unit = ...
if unit then
  for row in factiongroup() do
    if unit.faction == row.InternalName then
      return row.InternalName, row.Name_lang
    end
  end
end
