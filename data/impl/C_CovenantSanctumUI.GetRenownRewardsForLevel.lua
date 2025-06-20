local sql = ...
return function(covenantID, renownLevel)
  local t = {}
  for row in sql(covenantID, renownLevel) do
    table.insert(t, row)
  end
  return t
end
