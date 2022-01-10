local chrclasses, classID = ...
for row in chrclasses() do
  if row.ID == classID then
    return row.Name_lang, row.Filename, row.ID
  end
end
