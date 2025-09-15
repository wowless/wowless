return function()
  local function validate(r)
    if r.dirty then
      r.dirty = false
    end
    return r.valid
  end

  local function GetBottom(r)
    if validate(r) then
      return r.bottom
    end
  end

  local function GetCenter(r)
    if validate(r) then
      return (r.left + r.right) / 2, (r.bottom + r.top) / 2
    end
  end

  local function GetHeight(r, ignoreRect)
    if ignoreRect or not validate(r) then
      return r.height
    else
      return r.top - r.bottom
    end
  end

  local function GetLeft(r)
    if validate(r) then
      return r.left
    end
  end

  local function GetRect(r)
    if validate(r) then
      return r.left, r.bottom, r.right - r.left, r.top - r.bottom
    end
  end

  local function GetRight(r)
    if validate(r) then
      return r.right
    end
  end

  local function GetSize(r, ignoreRect)
    if ignoreRect or not validate(r) then
      return r.width, r.height
    else
      return r.right - r.left, r.top - r.bottom
    end
  end

  local function GetTop(r)
    if validate(r) then
      return r.top
    end
  end

  local function GetWidth(r, ignoreRect)
    if ignoreRect or not validate(r) then
      return r.width
    else
      return r.right - r.left
    end
  end

  local function IsRectValid(r)
    return r.valid and not r.dirty
  end

  local function SetHeight(r, h)
    if h ~= r.height then
      r.dirty = true
      r.height = h
    end
  end

  local function SetSize(r, w, h)
    if w ~= r.width or h ~= r.height then
      r.dirty = true
      r.width = w
      r.height = h
    end
  end

  local function SetWidth(r, w)
    if w ~= r.width then
      r.dirty = true
      r.width = w
    end
  end

  return {
    GetBottom = GetBottom,
    GetCenter = GetCenter,
    GetHeight = GetHeight,
    GetLeft = GetLeft,
    GetRect = GetRect,
    GetRight = GetRight,
    GetSize = GetSize,
    GetTop = GetTop,
    GetWidth = GetWidth,
    IsRectValid = IsRectValid,
    SetHeight = SetHeight,
    SetSize = SetSize,
    SetWidth = SetWidth,
  }
end
