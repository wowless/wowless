return function(self)
  if not self.parent or self.isIgnoringParentAlpha then
    return self.alpha
  else
    return self.parent:GetEffectiveAlpha() * self.alpha
  end
end
