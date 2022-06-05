local renownrewards, covenantID = ...
local t = {}
for row in renownrewards() do
  if row.CovenantID == covenantID then
    table.insert(t, {
      isCapstore = false,
      isMilestone = false,
      level = row.Level,
      locked = false,
    })
  end
end
table.sort(t, function(a, b)
  return a.level < b.level
end)
return t
