local api, env, log, uiobjects = ...
local validPoints = require('runtime.stringenums').FramePoint
local badpointErr = '%s:SetPoint(): Invalid region point %s'
local usageErr = table.concat({
  '%s:SetPoint(): Usage: (',
  '"point" [, region or nil] [, "relativePoint"] [, offsetX, offsetY]',
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
  local maybeRelativePoint = select(idx, ...)
  if type(maybeRelativePoint) == 'string' then
    relativePoint = maybeRelativePoint
    idx = idx + 1
  end
  local maybeX, maybeY = select(idx, ...)
  if type(maybeX) == 'number' and type(maybeY) == 'number' then
    x, y = maybeX, maybeY
  end
  if relativeTo ~= self then
    local newPoint = { point, relativeTo, relativePoint, x, y }
    for i, p in ipairs(self.points) do
      if p[1] == point then
        self.points[i] = newPoint
        return
      end
    end
    table.insert(self.points, newPoint)
  end
end
