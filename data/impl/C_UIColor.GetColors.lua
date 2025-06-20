local GetColorsSqlCursor = ...
return function()
  local t = {}
  for tag in GetColorsSqlCursor() do
    table.insert(t, {
      baseTag = tag,
      color = { -- TODO parse the color field
        r = 0.25,
        g = 0.35,
        b = 0.45,
        a = 1,
      },
    })
  end
  return t
end
