return function(self)
  repeat
    if not self.shown then
      return false
    end
    self = self.parent
  until not self
  return true
end
