local chrraces, unit = ...
if unit then
  for row in chrraces() do
    if row.ID == unit.race then
      return row.Name_lang, row.ClientFileString, row.ID
    end
  end
end
