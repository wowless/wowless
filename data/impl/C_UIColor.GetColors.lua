local env, GetColorsSqlCursor = ...
local mixin = require('wowless.util').mixin
return function()
  local t = {}
  for tag in GetColorsSqlCursor() do
    table.insert(t, {
      baseTag = tag,
      color = mixin({ -- TODO parse the color field
        r = 0.25,
        g = 0.35,
        b = 0.45,
        a = 1,
      }, env.env.ColorMixin),
    })
  end
  return t
end
