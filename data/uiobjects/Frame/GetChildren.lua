return function(self)
  local ret = {}
  for kid in self.children:entries() do
    table.insert(ret, kid)
  end
  return unpack(ret)
end
