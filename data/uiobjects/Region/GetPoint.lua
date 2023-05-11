return (function(self, index)
  local idx = tonumber(index) or 1
  if self.points[idx] then
    assert(type(self.points[idx][4]) ~= 'table')
    local point, relativeTo, relativePoint, x, y = unpack(self.points[idx])
    return point, relativeTo and relativeTo.luarep, relativePoint, x, y
  end
end)(...)
