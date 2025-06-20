local T = ...
return {
  noarg = function()
    T.assertEquals(false, pcall(T.env.UnitName))
  end,
  player = function()
    local name, realm = T.retn(2, T.env.UnitName('player'))
    return {
      name = function()
        assert(#name > 0)
      end,
      realm = function()
        T.assertEquals(nil, realm)
      end,
    }
  end,
  unknown = function()
    return T.match(2, nil, nil, T.env.UnitName('completeandutternonsense'))
  end,
}
