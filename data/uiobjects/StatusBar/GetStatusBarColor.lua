return function(self)
  local t = self.statusBarTexture
  if t then
    return t:GetVertexColor()
  else
    return 1, 1, 1, 1
  end
end
