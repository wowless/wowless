return function(self, scale)
  scale = assert(tonumber(scale)) -- TODO remove when coercion done horizontally
  if scale > 0 then
    self.scale = scale
  end
end
