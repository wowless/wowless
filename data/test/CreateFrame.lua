local t = ...
return {
  failures = function()
    local types = {
      'NonsenseType',
      'PingPin',
      'PingPinFrame',
    }
    local tt = {}
    for _, v in ipairs(types) do
      tt[v] = function()
        assert(not pcall(t.env.CreateFrame, v))
      end
    end
    return tt
  end,
}
