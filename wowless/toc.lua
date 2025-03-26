local flavors = require('runtime.flavors')

local suffixes = {}
for k, v in pairs(flavors) do
  local t = {
    '_' .. k,
    '-' .. k,
  }
  for _, alt in ipairs(v.alternates) do
    table.insert(t, '_' .. alt)
    table.insert(t, '-' .. alt)
  end
  table.insert(t, '_Standard')
  table.insert(t, '-Standard')
  table.insert(t, '')
  suffixes[k] = t
end

return function(flavor)
  return {
    suffixes = suffixes[flavor],
  }
end
