local chrclasses, classID = ...
local row = chrclasses(classID)
if row then
  return {
    className = row.Name_lang,
    classFile = row.Filename,
    classID = row.ID,
  }
end
