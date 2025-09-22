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
    'attempted from: %s:SetPoint.',
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

  local function SetPoint(r, point, ...)
    if point == nil then
      error(usageErr:format(r:GetObjectType()), 0)
    end
    local upoint = point:upper()
    if not validPoints[upoint] then
      error(badpointErr:format(r:GetObjectType(), point), 0)
    end
    local relativeTo = r.parent
    local relativePoint = upoint
    local x, y = 0, 0
    local idx = 1
    local maybeRelativeTo = select(idx, ...)
    if type(maybeRelativeTo) == 'string' then
      local name = ParentSub(maybeRelativeTo, relativeTo)
      local frame = genv[name]
      if not frame then
        log(1, 'SetPoint to unknown frame %q', name)
      end
      relativeTo = frame and UserData(frame)
      idx = idx + 1
    elseif type(maybeRelativeTo) == 'table' then
      relativeTo = UserData(maybeRelativeTo)
      idx = idx + 1
    elseif type(maybeRelativeTo) == 'nil' then
      idx = idx + 1
    end
    if relativeTo == r then
      error(selfErr:format(r:GetObjectType()), 0)
    end
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
    local newPoint = { upoint, relativeTo, relativePoint, x, y }
    local po = pointOrder[upoint]
    for i, p in ipairs(r.points) do
      if p[1] == point then
        r.points[i] = newPoint
        return
      elseif pointOrder[p[1]] > po then
        table.insert(r.points, i, newPoint)
        return
      end
    end
    table.insert(r.points, newPoint)
  end

  local function SetAllPoints(r)
    -- TODO handle relative argument to SetAllPoints
    local relative = nil
    SetPoint(r, 'TOPLEFT', relative, 'TOPLEFT', 0, 0)
    SetPoint(r, 'BOTTOMRIGHT', relative, 'BOTTOMRIGHT', 0, 0)
  end

  return {
    ClearAllPoints = ClearAllPoints,
    GetNumPoints = GetNumPoints,
    GetPoint = GetPoint,
    SetAllPoints = SetAllPoints,
    SetPoint = SetPoint,
  }
end
