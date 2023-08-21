return (function(self)
  local ret = {}
  for kid in self.animationGroups:entries() do
    table.insert(ret, kid.luarep)
  end
  return unpack(ret)
end)(...)
