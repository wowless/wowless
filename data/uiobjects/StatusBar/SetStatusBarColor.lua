return (function(self, ...)
  local t = u(self).statusBarTexture
  if t then
    return t:SetVertexColor(...)
  end
end)(...)
