local api = ...
return function(self, text)
  api.log(1, '[%s] %s', self:GetDebugName(), text)
end
