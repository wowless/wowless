local api, env, log, uiobjects = ...
local validPoints = require('runtime.stringenums').FramePoint
local pointsInOrder = {
  'TOPLEFT',
  'TOP',
  'TOPRIGHT',
  'LEFT',
  'CENTER',
  'RIGHT',
  'BOTTOMLEFT',
  'BOTTOM',
  'BOTTOMRIGHT',
}
local pointOrder = {}
for i, p in ipairs(pointsInOrder) do
  assert(validPoints[p], p)
  pointOrder[p] = i
end
for p in pairs(validPoints) do
  assert(pointOrder[p], p)
end
local badpointErr = '%s:SetPoint(): Invalid region point %s'
local badrelpointErr = '%s:SetPoint(): Unknown region point %s'
local usageErr = table.concat({
  '%s:SetPoint(): Usage: (',
  '"point" [, region or nil] [, "relativePoint"] [, offsetX, offsetY]',
})
local selfErr = table.concat({
  'Action[SetPoint] failed because',
  '[Cannot anchor to itself]: ',
  'attempted from: %s:SetPoint.',
})
return function(self, point, ...)
  -- TODO handle resetting points
  if point == nil then
    error(usageErr:format(self:GetObjectType()), 0)
  end
  local upoint = point:upper()
  if not validPoints[upoint] then
    error(badpointErr:format(self:GetObjectType(), point), 0)
  end
  local relativeTo = self.parent
  local relativePoint = upoint
  local x, y = 0, 0
  local idx = 1
  local maybeRelativeTo = select(idx, ...)
  if type(maybeRelativeTo) == 'string' then
    local name = api.ParentSub(maybeRelativeTo, relativeTo)
    local frame = env.genv[name]
    if not frame then
      log(1, 'SetPoint to unknown frame %q', name)
    end
    relativeTo = frame and uiobjects.UserData(frame)
    idx = idx + 1
  elseif type(maybeRelativeTo) == 'table' then
    relativeTo = uiobjects.UserData(maybeRelativeTo)
    idx = idx + 1
  elseif type(maybeRelativeTo) == 'nil' then
    idx = idx + 1
  end
  if relativeTo == self then
    error(selfErr:format(self:GetObjectType()), 0)
  end
  local maybeRelativePoint = select(idx, ...)
  if type(maybeRelativePoint) == 'string' then
    relativePoint = maybeRelativePoint:upper()
    if not validPoints[relativePoint] then
      error(badrelpointErr:format(self:GetObjectType(), maybeRelativePoint), 0)
    end
    idx = idx + 1
  end
  local maybeX, maybeY = select(idx, ...)
  if type(maybeX) == 'number' and type(maybeY) == 'number' then
    x, y = maybeX, maybeY
  end
  local newPoint = { upoint, relativeTo, relativePoint, x, y }
  local po = pointOrder[upoint]
  for i, p in ipairs(self.points) do
    if p[1] == point then
      self.points[i] = newPoint
      return
    elseif pointOrder[p[1]] > po then
      table.insert(self.points, i, newPoint)
      return
    end
  end
  table.insert(self.points, newPoint)
end
