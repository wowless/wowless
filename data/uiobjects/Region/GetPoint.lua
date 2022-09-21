return (function(self, index)
  local idx
  if type(index) == 'string' then
    local i = 1
    while not idx and i <= #u(self).points do
      if u(self).points[i][1] == index then
        idx = i
      end
      i = i + 1
    end
  else
    idx = index or 1
  end
  if u(self).points[idx] then
    assert(type(u(self).points[idx][4]) ~= 'table')
    return unpack(u(self).points[idx])
  else
    api.log(1, 'returning fake point')
    return 'CENTER', api.env.get('UIParent'), 'CENTER', 0, 0
  end
end)(...)
