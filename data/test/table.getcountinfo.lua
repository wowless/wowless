local T, getcountinfo = ...
local usage = '(Usage: local numTableNodes, numArrayNodes, maxArrayIndex = table.getcountinfo(table))'
return {
  array = function()
    return T.match(3, 5, 5, 5, getcountinfo({ 1, 2, 3, 4, 5 }))
  end,
  big = function()
    return T.match(3, 1, 1, 1000000, getcountinfo({ [1000000] = true }))
  end,
  empty = function()
    return T.match(3, 0, 0, 0, getcountinfo({}))
  end,
  hole = function()
    return T.match(3, 4, 4, 5, getcountinfo({ 1, 2, nil, 4, 5 }))
  end,
  keyvalue = function()
    return T.match(3, 3, 0, 0, getcountinfo({ a = true, b = true, c = true }))
  end,
  nilarg = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(getcountinfo, nil))
  end,
  none = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(getcountinfo))
  end,
  number = function()
    return T.match(2, false, 'bad argument #1 to \'?\' ' .. usage, pcall(getcountinfo, 42))
  end,
}
