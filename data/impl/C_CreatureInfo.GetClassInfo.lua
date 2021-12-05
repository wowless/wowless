local chrclasses, classID = ...
for row in chrclasses() do
  if row.ID == classID then
    return {
      className = row.Name_lang,
      classFile = row.Filename,
      classID = row.ID,
    }
  end
end
