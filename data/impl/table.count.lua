local usage = '(Usage: local numTableNodes, numArrayNodes, maxArrayIndex = table.count(table))'
local err = 'bad argument #1 to \'?\' ' .. usage
return function(t)
  if t == nil then
    error(err, 0)
  elseif type(t) == 'table' then
    local nt, na, ma = 0, 0, 0
    for k in pairs(t) do
      nt = nt + 1
      if type(k) == 'number' and k > 0 and math.floor(k) == k then
        na = na + 1
        ma = k > ma and k or ma
      end
    end
    return nt, na, ma
  end
end
