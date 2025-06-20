return function(self, index)
  local idx = tonumber(index) or 1
  if self.points[idx] then
    assert(type(self.points[idx][4]) ~= 'table')
    return unpack(self.points[idx])
  end
end
