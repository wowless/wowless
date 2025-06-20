local sql = ...
return function(classID)
  local ret = {}
  for subClassID in sql(classID) do
    table.insert(ret, subClassID)
  end
  return ret
end
