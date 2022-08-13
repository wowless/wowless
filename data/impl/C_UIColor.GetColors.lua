local globalcolor = ...
local t = {}
for row in globalcolor() do
  table.insert(t, {
    baseTag = row.LuaConstantName,
    color = { -- TODO parse the color field
      r = 0.25,
      g = 0.35,
      b = 0.45,
      a = 1,
    },
  })
end
return t
