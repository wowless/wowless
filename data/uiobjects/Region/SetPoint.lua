local validPoints = {
  BOTTOM = true,
  BOTTOMLEFT = true,
  BOTTOMRIGHT = true,
  CENTER = true,
  LEFT = true,
  RIGHT = true,
  TOP = true,
  TOPLEFT = true,
  TOPRIGHT = true,
}
return (function(self, point, ...)
  -- TODO handle resetting points
  point = point or 'CENTER'
  assert(validPoints[point])
  local relativeTo = self.parent and self.parent.luarep
  local relativePoint = point
  local x, y = 0, 0
  local idx = 1
  local maybeRelativeTo = select(idx, ...)
  if type(maybeRelativeTo) == 'string' then
    local name = api.ParentSub(maybeRelativeTo, relativeTo and u(relativeTo))
    local frame = api.env[name]
    if not frame then
      api.log(1, 'SetPoint to unknown frame %q', name)
    end
    relativeTo = frame
    idx = idx + 1
  elseif type(maybeRelativeTo) == 'table' then
    relativeTo = maybeRelativeTo
    idx = idx + 1
  elseif type(maybeRelativeTo) == 'nil' then
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
  if relativeTo ~= self.luarep then
    local newPoint = { point, relativeTo, relativePoint, x, y }
    for i, p in ipairs(self.points) do
      if p[1] == point then
        self.points[i] = newPoint
        return
      end
    end
    table.insert(self.points, newPoint)
  end
end)(...)
