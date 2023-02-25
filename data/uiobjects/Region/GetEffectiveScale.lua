return (function(self)
  if not self.parent or self.isIgnoringParentScale then
    return self.scale
  else
    return u(self.parent):GetEffectiveScale() * self.scale
  end
end)(...)
