local chrclasses, classTable, isFemale = ...
local col = isFemale and 'Name_female_lang' or 'Name_male_lang'
for row in chrclasses() do
  classTable[row.Filename] = row[col]
end
return classTable
