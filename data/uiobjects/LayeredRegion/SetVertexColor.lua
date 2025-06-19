return function(self, r, g, b, a)
  self.vertexColorR = tonumber(r) or 0
  self.vertexColorG = tonumber(g) or 0
  self.vertexColorB = tonumber(b) or 0
  self.vertexColorA = tonumber(a) or 1
end
