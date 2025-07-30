return function(self, key, clear)
  if clear then
    self:ClearParentKey()
  end
  self.parent.luarep[key] = self.luarep
end
