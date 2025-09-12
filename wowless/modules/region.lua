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

  local function GetSize(r)
    return r.width, r.height
  end

  local function GetTop(r)
    return r.bottom + r.height
  end

  local function GetWidth(r)
    return r.width
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
  }
end
