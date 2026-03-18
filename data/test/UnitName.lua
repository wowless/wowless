local T, UnitName = ...
return {
  noarg = function()
    T.assertEquals(false, pcall(UnitName))
  end,
  player = function()
    local name, realm = T.retn(2, UnitName('player'))
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
    return T.match(2, nil, nil, UnitName('completeandutternonsense'))
  end,
}
