local cursor = ...
return function(treeID)
  local t = {}
  for node in cursor(treeID) do
    table.insert(t, node)
  end
  return t
end
