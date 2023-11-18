local t = ...
return {
  noarg = function()
    t.assertEquals(false, pcall(t.env.UnitName))
  end,
  player = function()
    local name, realm = t.retn(2, t.env.UnitName('player'))
    return {
      name = function()
        assert(#name > 0)
      end,
      realm = function()
        t.assertEquals('', realm)
      end,
    }
  end,
  unknown = function()
    return t.check2('', '', t.env.UnitName('completeandutternonsense'))
  end,
}
