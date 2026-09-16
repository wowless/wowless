local T, single = ...
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
}
