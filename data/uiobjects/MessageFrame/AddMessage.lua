local log = ...
return function(self, text)
  log(1, '[%s] %s', self:GetDebugName(), text)
end
