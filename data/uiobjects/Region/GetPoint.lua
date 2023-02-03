return (function(self, index)
  local idx = tonumber(index) or 1
  if u(self).points[idx] then
    assert(type(u(self).points[idx][4]) ~= 'table')
    return unpack(u(self).points[idx])
  end
end)(...)
