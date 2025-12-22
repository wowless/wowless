return function()
  local function GetStatusBarColor(sb)
    local t = sb.statusBarTexture
    if t then
      return t:GetVertexColor()
    else
      return 1, 1, 1, 1
    end
  end

  local function SetStatusBarColor(sb, r, g, b, a)
    local t = sb.statusBarTexture
    if t then
      return t:SetVertexColor(r, g, b, a)
    end
  end

  return {
    GetStatusBarColor = GetStatusBarColor,
    SetStatusBarColor = SetStatusBarColor,
  }
end
