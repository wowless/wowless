local T = ...
return {
  failures = function()
    local types = {
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
