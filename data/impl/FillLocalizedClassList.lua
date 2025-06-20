local sql = ...
return function(classTable, isFemale)
  for filename, name in sql(isFemale) do
    classTable[filename] = name
  end
  return classTable
end
