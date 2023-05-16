local self = ...
for k, v in pairs(self.parent.luarep) do
  if self.luarep == v then
    return k
  end
end
return nil
