return function(self)
  local ret = {}
  for kid in self.animations:entries() do
    table.insert(ret, kid)
  end
  return unpack(ret)
end
