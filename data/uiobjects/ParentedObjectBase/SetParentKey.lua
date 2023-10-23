local self, key = ...
if self.ClearParentKey then
  self:ClearParentKey()
end
self.parent.luarep[key] = self.luarep
