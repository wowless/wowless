return (function(self, r, g, b, a)
  local ud = u(self)
  ud.vertexColorR = tonumber(r) or 0
  ud.vertexColorG = tonumber(g) or 0
  ud.vertexColorB = tonumber(b) or 0
  ud.vertexColorA = tonumber(a) or 1
end)(...)
