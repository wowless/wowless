local chrclasses, classID = ...
local row = chrclasses(classID)
if row then
  return row.Name_lang, row.Filename, row.ID
end
