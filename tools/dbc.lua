local dbcrows = require('dbc').rows

local function rows(content, sig)
  if content:sub(1, 4) == 'WDC4' then
    content = 'WDC3' .. content:sub(5)
  end
  return dbcrows(content, sig)
end

return {
  rows = rows,
}
