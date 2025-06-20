return function(self)
  for k, v in pairs(self.parent.luarep) do
    if self.luarep == v then
      self.parent.luarep[k] = nil
    end
  end
end
