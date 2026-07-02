-- The real client can't report meaningful MinValue/MaxValue for these
-- 64-bit bitflag enums, which we represent as hex strings since Lua 5.1
-- numbers can't hold them precisely; it reports fixed sentinels instead.
-- issue #527
local sentinels = {
  AccountStateLoadedFlags = { MaxValue = -2147483648, MinValue = 0 },
  CreateAllAccountData = { MaxValue = -2147483648, MinValue = 0 },
}

local function computeMeta(name, values)
  local count = 0
  for _ in pairs(values) do
    count = count + 1
  end
  local sentinel = sentinels[name]
  if sentinel then
    return {
      MaxValue = sentinel.MaxValue,
      MinValue = sentinel.MinValue,
      NumValues = count,
    }
  end
  local min, max
  for _, v in pairs(values) do
    if min == nil or v < min then
      min = v
    end
    if v >= 0 and (max == nil or v > max) then
      max = v
    end
  end
  return {
    MaxValue = max ~= nil and (max < 2 ^ 31 and max or max - 2 ^ 32) or nil,
    MinValue = min,
    NumValues = count,
  }
end

return {
  computeMeta = computeMeta,
}
