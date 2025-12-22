return function()
  local function GetStatusBarColor(sb)
    local t = sb.statusBarTexture
    if t then
      return t:GetVertexColor()
    else
      return 1, 1, 1, 1
    end
  end

  -- TODO support interpolation
  local function SetMinMaxValues(sb, min, max)
    sb.min = min
    sb.max = max
  end

  local function SetStatusBarColor(sb, r, g, b, a)
    local t = sb.statusBarTexture
    if t then
      return t:SetVertexColor(r, g, b, a)
    end
  end

  -- TODO support interpolation
  local function SetValue(sb, value)
    sb.value = value
  end

  return {
    GetStatusBarColor = GetStatusBarColor,
    SetMinMaxValues = SetMinMaxValues,
    SetStatusBarColor = SetStatusBarColor,
    SetValue = SetValue,
  }
end
