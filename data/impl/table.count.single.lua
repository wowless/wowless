local usage = '(Usage: local numTableNodes, numArrayNodes, maxArrayIndex = table.count(table))'
local err = 'bad argument #1 to \'?\' ' .. usage
return function(t)
  if t == nil then
    error(err, 0)
  elseif type(t) == 'table' then
    local n = 0
    for _ in pairs(t) do
      n = n + 1
    end
    return n
  end
end
