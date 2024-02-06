return (function(self)
  local ret = {}
  for kid in self.children:entries() do
    if kid:IsObjectType('layeredregion') then
      table.insert(ret, kid.luarep)
    end
  end
  return unpack(ret)
end)(...)
