return function()
  local function GetBottom(r)
    return r.bottom
  end

  local function GetCenter(r)
    return r.left + r.width / 2, r.bottom + r.height / 2
  end

  local function GetHeight(r)
    return r.height
  end

  local function GetLeft(r)
    return r.left
  end

  local function GetRect(r)
    return r.left, r.bottom, r.width, r.height
  end

  local function GetRight(r)
    return r.left + r.width
  end

  local function GetScaledRect(r)
    local s = r:GetEffectiveScale()
    return r.left * s, r.bottom * s, r.width * s, r.height * s
  end

  local function GetSize(r)
    return r.width, r.height
  end

  local function GetTop(r)
    return r.bottom + r.height
  end

  local function GetWidth(r)
    return r.width
  end

  local function IsRectValid()
    return false
  end

  local function SetHeight(r, h)
    r.height = h
  end

  local function SetSize(r, w, h)
    r.width = w
    r.height = h
  end

  local function SetWidth(r, w)
    r.width = w
  end

  return {
    GetBottom = GetBottom,
    GetCenter = GetCenter,
    GetHeight = GetHeight,
    GetLeft = GetLeft,
    GetRect = GetRect,
    GetRight = GetRight,
    GetScaledRect = GetScaledRect,
    GetSize = GetSize,
    GetTop = GetTop,
    GetWidth = GetWidth,
    IsRectValid = IsRectValid,
    SetHeight = SetHeight,
    SetSize = SetSize,
    SetWidth = SetWidth,
  }
end
