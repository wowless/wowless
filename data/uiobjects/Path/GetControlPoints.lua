return function(self)
  local ret = {}
  for kid in self.controlPoints:entries() do
    table.insert(ret, kid)
  end
  return unpack(ret)
end
