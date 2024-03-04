local T = ...
return {
  failures = function()
    local types = {
      -- 'ModelFFX', -- glue only TODO reenable when we can handle different warnings
      'NonsenseType',
      'PingPin',
      'PingPinFrame',
    }
    local t = {}
    for _, v in ipairs(types) do
      t[v] = function()
        assert(not pcall(T.env.CreateFrame, v))
      end
    end
    return t
  end,
}
