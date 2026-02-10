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
  local cycleErr = table.concat({
    'Action[SetPoint] failed because',
    '[Cannot anchor to a region dependent on it]: ',
    'attempted from: %s:%s.\n',
    'Relative: [%s]\n',
    'Dependent: [%s]',
  })

  local function ClearAllPoints(r)
    table.wipe(r.points)
  end

  local function ClearPoint(r, point)
    r.points[point] = nil
  end

  local function GetNumPoints(r)
    local n = 0
    for _ in pairs(r.points) do
      n = n + 1
    end
    return n
  end

  local function GetPoint(r, index)
    local k = 0
    for _, p in ipairs(pointsInOrder) do
      local rp = r.points[p]
      if rp then
        k = k + 1
        if k == index then
          return p, unpack(rp)
        end
      end
    end
  end

  local function GetPointByName(r, point)
    local rp = r.points[point]
    if rp then
      return point, unpack(rp)
    end
  end

  local function rstr(r)
    return tostring(r):gsub('^.*0x(.*)$', '%1')
  end

  local function cycleCheck(r, relativeTo, fn)
    local queue = { relativeTo }
    local seen = {}
    local n = 1
    repeat
      local x = queue[n]
      n = n - 1
      for _, p in pairs(x.points) do
        local y = p[1]
        if y == r then
          local err = cycleErr:format(r:GetObjectType(), fn, rstr(relativeTo.luarep), rstr(x.luarep))
          local anc = {}
          local z = seen[x]
          while z do
            table.insert(anc, '[' .. rstr(z.luarep) .. ']')
            z = seen[z]
          end
          local extra = next(anc) and '\nDependent ancestors:\n' .. table.concat(anc, '\n') or ''
          error(err .. extra, 0)
        elseif y and not seen[y] then
          seen[y] = x
          n = n + 1
          queue[n] = y
        end
      end
    until n == 0
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
    elseif relativeTo then
      cycleCheck(r, relativeTo, fn)
    end
    return relativeTo
  end

  local function SetPointInternal(r, point, relativeTo, relativePoint, x, y)
    r.points[point] = { relativeTo, relativePoint, x, y }
    r.dirty = true
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
    ClearPoint = ClearPoint,
    GetNumPoints = GetNumPoints,
    GetPoint = GetPoint,
    GetPointByName = GetPointByName,
    SetAllPoints = SetAllPoints,
    SetAllPointsInternal = SetAllPointsInternal,
    SetPoint = SetPoint,
    SetPointInternal = SetPointInternal,
  }
end
