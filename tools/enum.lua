local function computeMeta(values, metafix)
  local k1, v1 = next(values)
  local min, max, count = v1, v1, 1
  for _, v in next, values, k1 do
    count = count + 1
    min = v < min and v or min
    max = v > max and v or max
  end
  if type(v1) ~= 'string' then
    return {
      MaxValue = (metafix or max < 2 ^ 31) and max or max - 2 ^ 32,
      MinValue = min,
      NumValues = count,
    }
  elseif metafix then
    return {
      MaxValue = max,
      MinValue = min,
      NumValues = ('0x%016x'):format(count),
    }
  else
    return {
      MaxValue = -2147483648,
      MinValue = 0,
      NumValues = count,
    }
  end
end

return {
  computeMeta = computeMeta,
}
