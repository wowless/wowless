return function(system, visibility)
  local IsVisible = visibility.IsVisible

  local screen = {
    bottom = 0,
    left = 0,
    right = system.GetScreenWidth(),
    top = system.GetScreenHeight(),
  }

  local validate

  local function validated(p)
    return p and (not p[1] or validate(p[1])) and p
  end

  function validate(r)
    if r.dirty then
      r.dirty = false
      local p = r.points
      local tp = validated(p.TOPLEFT) or validated(p.TOP) or validated(p.TOPRIGHT)
      local lp = validated(p.TOPLEFT) or validated(p.LEFT) or validated(p.BOTTOMLEFT)
      local bp = validated(p.BOTTOMLEFT) or validated(p.BOTTOM) or validated(p.BOTTOMRIGHT)
      local rp = validated(p.TOPRIGHT) or validated(p.RIGHT) or validated(p.BOTTOMRIGHT)
      local mxp = validated(p.TOP) or validated(p.CENTER) or validated(p.BOTTOM)
      local myp = validated(p.LEFT) or validated(p.CENTER) or validated(p.BOTTOM)
      if tp or lp or bp or rp or mxp or myp then
        screen = screen -- TODO something
      end
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

  local function GetScaledRect(r)
    if validate(r) then
      local s = r:GetEffectiveScale()
      return r.left * s, r.bottom * s, (r.right - r.left) * s, (r.top - r.bottom) * s
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

  local function IsCollapsed(r)
    return r.collapsesLayout and not IsVisible(r)
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
    GetScaledRect = GetScaledRect,
    GetSize = GetSize,
    GetTop = GetTop,
    GetWidth = GetWidth,
    IsCollapsed = IsCollapsed,
    IsRectValid = IsRectValid,
    SetHeight = SetHeight,
    SetSize = SetSize,
    SetWidth = SetWidth,
  }
end
