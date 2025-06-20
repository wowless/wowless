return function(self)
  local n = 0
  for kid in self.children:entries() do
    if kid:IsObjectType('frame') then
      n = n + 1
    end
  end
  return n
end
