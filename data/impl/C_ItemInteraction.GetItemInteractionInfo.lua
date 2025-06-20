-- TODO: nil when UI is not open; use appropriate row based on open UI
local sql = ...
return function()
  return sql(3)
end
