local sql = ...
local t = {}
for row in sql() do
  table.insert(t, row)
end
return t
