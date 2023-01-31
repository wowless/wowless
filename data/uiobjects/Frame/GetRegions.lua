return (function(self)
  local ret = {}
  for kid in u(self).children:entries() do
    if api.InheritsFrom(u(kid).type, 'layeredregion') then
      table.insert(ret, kid)
    end
  end
  return unpack(ret)
end)(...)
