return (function(self)
  local ret = {}
  for kid in kids(self) do
    if api.InheritsFrom(u(kid).type, 'animation') then
      table.insert(ret, kid)
    end
  end
  return unpack(ret)
end)(...)
