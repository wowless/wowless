return (function(self, point, ...)
  -- TODO handle resetting points
  point = point or 'CENTER'
  local relativeTo = u(self).parent
  local relativePoint = 'CENTER'
  local x, y = 0, 0
  local idx = 1
  local maybeRelativeTo = select(idx, ...)
  if type(maybeRelativeTo) == 'string' then
    local name = api.ParentSub(maybeRelativeTo, relativeTo)
    local frame = api.env[name]
    if not frame then
      api.log(1, 'SetPoint to unknown frame %q', name)
    end
    relativeTo = frame
    idx = idx + 1
  elseif type(maybeRelativeTo) == 'table' then
    relativeTo = maybeRelativeTo
    idx = idx + 1
  end
  local maybeRelativePoint = select(idx, ...)
  if type(maybeRelativePoint) == 'string' then
    relativePoint = maybeRelativePoint
    idx = idx + 1
  end
  local maybeX, maybeY = select(idx, ...)
  if type(maybeX) == 'number' and type(maybeY) == 'number' then
    x, y = maybeX, maybeY
  end
  local newPoint = { point, relativeTo, relativePoint, x, y }
  for i, p in ipairs(u(self).points) do
    if p[1] == point then
      u(self).points[i] = newPoint
      return
    end
  end
  table.insert(u(self).points, newPoint)
end)(...)
