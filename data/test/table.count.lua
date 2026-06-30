local T, count = ...
local usage = '(Usage: local numTableNodes, numArrayNodes, maxArrayIndex = table.count(table))'
return {
  array = function()
    return T.match(3, 5, 5, 5, count({ 1, 2, 3, 4, 5 }))
  end,
  big = function()
    return T.match(3, 1, 1, 1000000, count({ [1000000] = true }))
  end,
  empty = function()
    return T.match(3, 0, 0, 0, count({}))
  end,
  hole = function()
    return T.match(3, 4, 4, 5, count({ 1, 2, nil, 4, 5 }))
  end,
  keyvalue = function()
    return T.match(3, 3, 0, 0, count({ a = true, b = true, c = true }))
  end,
  nilarg = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(count, nil))
  end,
  none = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(count))
  end,
  number = function()
    return T.match(0, count(42))
  end,
}
