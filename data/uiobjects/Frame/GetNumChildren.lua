return function(self)
  local n = 0
  for _ in self.children:entries() do
    n = n + 1
  end
  return n
end
