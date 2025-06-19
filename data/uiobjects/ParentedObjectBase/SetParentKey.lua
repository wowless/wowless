return function(self, key, clear)
  if self.ClearParentKey and clear then
    self:ClearParentKey()
  end
  self.parent.luarep[key] = self.luarep
end
