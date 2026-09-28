local T, UnitName = ...
return {
  noarg = function()
    T.assertEquals(false, pcall(UnitName))
  end,
  player = function()
    local name, second = T.retn(2, UnitName('player'))
    local cfg = T.data.config.modules and T.data.config.modules.units or {}
    return {
      name = function()
        assert(#name > 0)
      end,
      second = function()
        if cfg.lastnames then
          assert(#second > 0)
        else
          T.assertEquals(nil, second)
        end
      end,
    }
  end,
  unknown = function()
    return T.match(2, nil, nil, UnitName('completeandutternonsense'))
  end,
}
