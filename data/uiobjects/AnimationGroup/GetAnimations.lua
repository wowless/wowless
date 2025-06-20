return function(self)
  local ret = {}
  for kid in self.children:entries() do
    if kid:IsObjectType('animation') then
      table.insert(ret, kid)
    end
  end
  return unpack(ret)
end
