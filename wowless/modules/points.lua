return function(api, env, log, uiobjects)
  local genv = env.genv
  local ParentSub = api.ParentSub
  local UserData = uiobjects.UserData

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
    'attempted from: %s:%s.',
  })

  local function ClearAllPoints(r)
    table.wipe(r.points)
  end

  local function GetNumPoints(r)
    return #r.points
  end

  local function GetPoint(r, index)
    local p = r.points[index]
    if p then
      return unpack(p)
    end
  end

  local function resolveRelativeTo(r, fn, ...)
    if select('#', ...) == 0 then
      return r.parent
    end
    local arg = select(1, ...)
    if arg == nil then
      return nil
    end
    local relativeTo
    if type(arg) == 'string' then
      local name = ParentSub(arg, r.parent)
      local frame = genv[name]
      if not frame then
        log(1, 'SetPoint to unknown frame %q', name)
      end
      relativeTo = frame and UserData(frame)
    elseif type(arg) == 'table' then
      relativeTo = UserData(arg)
    end
    if relativeTo == r then
      error(selfErr:format(r:GetObjectType(), fn), 0)
    end
    return relativeTo
  end

  local function SetPointInternal(r, point, relativeTo, relativePoint, x, y)
    local t = { point, relativeTo, relativePoint, x, y }
    local po = pointOrder[point]
    for i, p in ipairs(r.points) do
      if p[1] == point then
        r.points[i] = t
        return
      elseif pointOrder[p[1]] > po then
        table.insert(r.points, i, t)
        return
      end
    end
    table.insert(r.points, t)
  end

  local function SetPoint(r, point, ...)
    if point == nil then
      error(usageErr:format(r:GetObjectType()), 0)
    end
    local upoint = point:upper()
    if not validPoints[upoint] then
      error(badpointErr:format(r:GetObjectType(), point), 0)
    end
    local relativeTo = resolveRelativeTo(r, 'SetPoint', ...)
    local relativePoint = upoint
    local x, y = 0, 0
    local idx = 2
    local maybeRelativePoint = select(idx, ...)
    if type(maybeRelativePoint) == 'string' then
      relativePoint = maybeRelativePoint:upper()
      if not validPoints[relativePoint] then
        error(badrelpointErr:format(r:GetObjectType(), maybeRelativePoint), 0)
      end
      idx = idx + 1
    end
    local maybeX, maybeY = select(idx, ...)
    if type(maybeX) == 'number' and type(maybeY) == 'number' then
      x, y = maybeX, maybeY
    end
    SetPointInternal(r, upoint, relativeTo, relativePoint, x, y)
  end

  local function SetAllPointsInternal(r, relativeTo)
    SetPointInternal(r, 'TOPLEFT', relativeTo, 'TOPLEFT', 0, 0)
    SetPointInternal(r, 'BOTTOMRIGHT', relativeTo, 'BOTTOMRIGHT', 0, 0)
  end

  local function SetAllPoints(r, ...)
    SetAllPointsInternal(r, resolveRelativeTo(r, 'SetAllPoints', ...))
  end

  return {
    ClearAllPoints = ClearAllPoints,
    GetNumPoints = GetNumPoints,
    GetPoint = GetPoint,
    SetAllPoints = SetAllPoints,
    SetAllPointsInternal = SetAllPointsInternal,
    SetPoint = SetPoint,
    SetPointInternal = SetPointInternal,
  }
end
