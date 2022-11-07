local cursor, treeID = ...
local t = {}
for node in cursor(treeID) do
  table.insert(t, node)
end
return t
