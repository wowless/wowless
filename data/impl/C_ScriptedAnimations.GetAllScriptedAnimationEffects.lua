local sql = ...
return function()
  local t = {}
  for row in sql() do
    row.useTargetAsSource = row.useTargetAsSource == 1
    table.insert(t, row)
  end
  return t
end
