local T, single = ...
local usage = '(Usage: local numTableNodes, numArrayNodes, maxArrayIndex = table.count(table))'
return {
  array = function()
    return T.match(1, 5, single({ 1, 2, 3, 4, 5 }))
  end,
  big = function()
    return T.match(1, 1, single({ [1000000] = true }))
  end,
  empty = function()
    return T.match(1, 0, single({}))
  end,
  hole = function()
    return T.match(1, 4, single({ 1, 2, nil, 4, 5 }))
  end,
  keyvalue = function()
    return T.match(1, 3, single({ a = true, b = true, c = true }))
  end,
  nilarg = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(single, nil))
  end,
  none = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(single))
  end,
  number = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(single, 42))
  end,
}
