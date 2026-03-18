local T, error = ...
return {
  nullary = function()
    return T.match(2, false, nil, pcall(error))
  end,
  unary = function()
    return T.match(2, false, 'moo', pcall(error, 'moo'))
  end,
}
