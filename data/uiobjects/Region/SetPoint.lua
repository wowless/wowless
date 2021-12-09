return (function(self, point, ...)
  -- TODO handle resetting points
  point = point or 'CENTER'
  local relativeTo = u(self).parent
  local relativePoint = 'CENTER'
  local x, y = 0, 0
  local idx = 1
  if type(select(idx, ...) or nil) == 'string' then
    local name = api.ParentSub(select(idx, ...), relativeTo)
    local frame = api.env[name]
    if not frame then
      api.log(1, 'SetPoint to unknown frame %q', name)
    end
    relativeTo = frame
    idx = idx + 1
  elseif type(select(idx, ...) or nil) == 'table' then
    relativeTo = select(idx, ...)
    idx = idx + 1
  end
  if type(select(idx, ...) or nil) == 'string' then
    relativePoint = select(idx, ...)
    idx = idx + 1
  end
  local xx, yy = select(idx, ...)
  if type(xx) == 'number' and type(yy) == 'number' then
    x, y = xx, yy
  end
  table.insert(u(self).points, { point, relativeTo, relativePoint, x, y })
end)(...)
