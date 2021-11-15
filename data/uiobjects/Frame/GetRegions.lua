return (function(self)
  local ret = {}
  for kid in kids(self) do
    if api.InheritsFrom(u(kid).type, 'layeredregion') then
      table.insert(ret, kid)
    end
  end
  return unpack(ret)
end)(...)
