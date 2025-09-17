return function(self, index)
  if self.points[index] then
    return unpack(self.points[index])
  end
end
