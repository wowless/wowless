local sql = ...
return function()
  local t = {}
  for id in sql() do
    table.insert(t, id)
  end
  return t
end
