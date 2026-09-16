return function(t)
  local n = 0
  for _ in pairs(t) do
    n = n + 1
  end
  return n
end
