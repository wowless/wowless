return function(self, ...)
  local t = self.statusBarTexture
  if t then
    return t:SetVertexColor(...)
  end
end
