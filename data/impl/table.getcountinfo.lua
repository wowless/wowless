return function(t)
  local nt, na, ma = 0, 0, 0
  for k in pairs(t) do
    nt = nt + 1
    if type(k) == 'number' and k > 0 and math.floor(k) == k then
      na = na + 1
      ma = k > ma and k or ma
    end
  end
  return nt, na, ma
end
