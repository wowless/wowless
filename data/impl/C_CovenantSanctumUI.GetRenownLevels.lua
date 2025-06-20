local sql = ...
return function(covenantID)
  local t = {}
  for level in sql(covenantID) do
    table.insert(t, {
      isCapstone = false,
      isMilestone = false,
      level = level,
      locked = false,
    })
  end
  return t
end
