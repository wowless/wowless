local T = ...
return {
  nullary = function()
    return T.match(2, false, nil, pcall(T.env.error))
  end,
  unary = function()
    return T.match(2, false, 'moo', pcall(T.env.error, 'moo'))
  end,
}
